const baseURL = 'https://api.devguide.help/api/';

// Mock data for development/offline mode
const MOCK_MODE = false; // Set to false when API is available

// Mobile detection function
function isMobileDevice() {
  // Check user agent for mobile devices
  const userAgent = navigator.userAgent || navigator.vendor || window.opera;
  
  // Mobile device patterns
  const mobilePatterns = [
    /Android/i,
    /webOS/i,
    /iPhone/i,
    /iPad/i,
    /iPod/i,
    /BlackBerry/i,
    /Windows Phone/i,
    /Mobile/i,
    /Tablet/i
  ];
  
  // Check if any mobile pattern matches
  const isMobileUA = mobilePatterns.some(pattern => pattern.test(userAgent));
  
  // Additional checks for touch devices and screen size
  const isTouchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
  const isSmallScreen = window.innerWidth <= 768;
  
  // Combine checks - prioritize user agent but also consider touch and screen size
  return isMobileUA || (isTouchDevice && isSmallScreen);
}

// Check if user has already visited (to avoid redirecting returning users)
function isFirstVisit() {
  const hasVisited = localStorage.getItem('devguide_has_visited');
  if (!hasVisited) {
    localStorage.setItem('devguide_has_visited', 'true');
    return true;
  }
  return false;
}

// Check if user preference is set to skip mobile redirect
function shouldSkipMobileRedirect() {
  return localStorage.getItem('devguide_skip_mobile_redirect') === 'true';
}

// Function to set user preference to skip mobile redirect
function setSkipMobileRedirect() {
  localStorage.setItem('devguide_skip_mobile_redirect', 'true');
}

let mockCommunityQuestions = [
  {
    id: 1,
    text: "How do I get started with React?",
    user: { full_name: "John Doe", profile_picture: "Layer_1.svg" },
    upvotes: 5,
    comments: [
      { id: 1, text: "Start with the official React tutorial!", user: { full_name: "Jane Smith", profile_picture: "Layer_1.svg" } }
    ],
    created_at: new Date(Date.now() - 3600000).toISOString() // 1 hour ago
  },
  {
    id: 2,
    text: "What's the best way to learn JavaScript?",
    user: { full_name: "Alice Johnson", profile_picture: "Layer_1.svg" },
    upvotes: 8,
    comments: [],
    created_at: new Date(Date.now() - 7200000).toISOString() // 2 hours ago
  }
];

let mockCommunityUsers = {
  "john@example.com": 15,
  "jane@example.com": 12,
  "alice@example.com": 8
};

// Current profile will be initialized in fetchCurrentProfile

let pendingTrackId = null;
let pendingLanguageName = null;

// Chatbot session tracking
let chatbotModalWelcomeShown = false;
let chatbotPageWelcomeShown = false;

// Enhanced performance with debouncing and throttling
const debounce = (func, wait) => {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
};

const throttle = (func, limit) => {
  let inThrottle;
  return function() {
    const args = arguments;
    const context = this;
    if (!inThrottle) {
      func.apply(context, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  }
};

// Enhanced accessibility features
const announceToScreenReader = (message) => {
  const announcement = document.createElement('div');
  announcement.setAttribute('aria-live', 'polite');
  announcement.setAttribute('aria-atomic', 'true');
  announcement.className = 'sr-only';
  announcement.textContent = message;
  document.body.appendChild(announcement);
  setTimeout(() => document.body.removeChild(announcement), 1000);
};

// Enhanced loading states
const showLoadingState = (element, message = 'Loading...') => {
  if (!element) return;
  element.classList.add('loading');
  element.setAttribute('aria-busy', 'true');
  element.setAttribute('aria-label', message);
  
  // Add loading spinner if not exists
  if (!element.querySelector('.loading-spinner')) {
    const spinner = document.createElement('div');
    spinner.className = 'loading-spinner';
    spinner.innerHTML = '<div class="spinner"></div>';
    element.appendChild(spinner);
  }
};

const hideLoadingState = (element) => {
  if (!element) return;
  element.classList.remove('loading');
  element.removeAttribute('aria-busy');
  element.removeAttribute('aria-label');
  
  const spinner = element.querySelector('.loading-spinner');
  if (spinner) spinner.remove();
};

// Enhanced error handling with retry mechanism
class APIError extends Error {
  constructor(message, status, endpoint) {
    super(message);
    this.name = 'APIError';
    this.status = status;
    this.endpoint = endpoint;
  }
}

const apiCall = async (endpoint, options = {}, retries = 3) => {
  const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));
  
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(`${baseURL}${endpoint}`, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...options.headers
        }
      });
      
      if (!response.ok) {
        throw new APIError(
          `HTTP ${response.status}: ${response.statusText}`,
          response.status,
          endpoint
        );
      }
      
      return await response.json();
    } catch (error) {
      if (i === retries - 1) throw error;
      await delay(Math.pow(2, i) * 1000); // Exponential backoff
    }
  }
};

// Global error formatter and modal display with enhanced UX
function formatErrors(err) {
  if (!err) return '';
  if (typeof err === 'string') return err;
  if (err.detail) return err.detail;
  if (err instanceof APIError) {
    return `Network error: ${err.message}. Please check your connection and try again.`;
  }
  if (typeof err === 'object') {
    return Object.values(err).flat().join(' ');
  }
  return String(err);
}

function showMessage(msg, callback, type = 'info') {
  const modal = document.getElementById('message-modal');
  const textEl = document.getElementById('message-modal-text');
  const closeBtn = modal.querySelector('.modal-close');
  
  // Enhanced message styling based on type
  modal.className = `modal message-modal message-${type}`;
  textEl.textContent = msg;
  
  // Accessibility improvements
  modal.setAttribute('role', 'dialog');
  modal.setAttribute('aria-modal', 'true');
  modal.setAttribute('aria-labelledby', 'message-modal-text');
  
  modal.classList.remove('hidden');
  
  // Focus management
  const previousFocus = document.activeElement;
  closeBtn.focus();
  
  const handleClose = () => {
    modal.classList.add('hidden');
    previousFocus?.focus(); // Restore focus
    announceToScreenReader('Dialog closed');
    if (callback) callback();
  };
  
  // Enhanced keyboard navigation
  const handleKeyDown = (e) => {
    if (e.key === 'Escape') {
      handleClose();
      modal.removeEventListener('keydown', handleKeyDown);
    }
  };
  
  modal.addEventListener('keydown', handleKeyDown);
  closeBtn.onclick = handleClose;
  modal.onclick = (e) => { 
    if (e.target === modal) handleClose();
  };
  
  announceToScreenReader(`${type} message: ${msg}`);
  
  // Use enhanced notification system if available
  if (window.notificationManager && type !== 'info') {
    window.notificationManager[type](msg.split(':')[0] || 'Notification', msg.split(':')[1] || msg);
  }
}

// --- Enhanced Community Q&A, Leaderboard, and Gamification ---
const APP_LOGO = 'Layer_1.svg';
const COMMUNITY_QUESTIONS_PAGE_SIZE = 3;
const COMMUNITY_LEADERBOARD_PAGE_SIZE = 3;

let currentProfile = MOCK_MODE ? 
  { full_name: 'Demo User', profile_picture: APP_LOGO, email: 'demo@devguide.help' } :
  { full_name: 'Guest', profile_picture: APP_LOGO };

// Test function to verify mock system
function testMockSystem() {
  console.log('🧪 Testing Mock System');
  console.log('MOCK_MODE:', MOCK_MODE);
  console.log('currentProfile:', currentProfile);
  console.log('mockCommunityQuestions:', mockCommunityQuestions.length, 'questions');
  console.log('mockCommunityUsers:', Object.keys(mockCommunityUsers).length, 'users');
  console.log('isLoggedIn():', isLoggedIn());
}

// Chatbot welcome message function
function showChatbotWelcome(chatDiv, isModal = false) {
  const welcomeMessages = [
    "👋 Hi there! I'm DevGuide AI, your personal programming assistant!",
    "🚀 I'm here to help you with anything programming-related - from syntax questions to best practices.",
    "💡 Feel free to ask me about any programming language, framework, or development concept you're learning!",
    "✨ Let's code together! What can I help you with today?"
  ];
  
  // Show welcome messages with delay
  welcomeMessages.forEach((message, index) => {
    setTimeout(() => {
      const messageDiv = document.createElement('div');
      messageDiv.className = 'message bot';
      messageDiv.innerHTML = message;
      chatDiv.appendChild(messageDiv);
      
      // Auto-scroll to bottom
      chatDiv.scrollTop = chatDiv.scrollHeight;
    }, (index + 1) * 800); // 800ms delay between messages
  });
  
  // Mark welcome as shown for this session
  if (isModal) {
    chatbotModalWelcomeShown = true;
  } else {
    chatbotPageWelcomeShown = true;
  }
}

// Enhanced API-based community functions with caching
const cache = new Map();
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes

const getCachedData = (key) => {
  const cached = cache.get(key);
  if (cached && Date.now() - cached.timestamp < CACHE_DURATION) {
    return cached.data;
  }
  cache.delete(key);
  return null;
};

const setCachedData = (key, data) => {
  cache.set(key, { data, timestamp: Date.now() });
};

async function getCommunityQuestions() {
  const cacheKey = 'community-questions';
  const cached = getCachedData(cacheKey);
  if (cached) return cached;
  
  // Use mock data in development mode or when API is unavailable
  if (MOCK_MODE) {
    setCachedData(cacheKey, mockCommunityQuestions);
    return mockCommunityQuestions;
  }
  
  try {
    const token = localStorage.getItem('token');
    const headers = token ? { 'Authorization': `Bearer ${token}` } : {};
    const data = await apiCall('community/questions/', { headers });
    const questions = Array.isArray(data) ? data : (data.results || []);
    setCachedData(cacheKey, questions);
    return questions;
  } catch (e) {
    console.error('Error fetching community questions:', e);
    announceToScreenReader('Failed to load community questions');
    // Fallback to mock data if API fails
    setCachedData(cacheKey, mockCommunityQuestions);
    return mockCommunityQuestions;
  }
}

async function getCommunityUsers() {
  const cacheKey = 'community-users';
  const cached = getCachedData(cacheKey);
  if (cached) return cached;
  
  // Use mock data in development mode or when API is unavailable
  if (MOCK_MODE) {
    setCachedData(cacheKey, mockCommunityUsers);
    return mockCommunityUsers;
  }
  
  try {
    const token = localStorage.getItem('token');
    const headers = token ? { 'Authorization': `Bearer ${token}` } : {};
    const data = await apiCall('community/leaderboard/', { headers });
    const leaderboard = Array.isArray(data) ? data : (data.results || []);
    
    // Convert to users object format
    const users = {};
    leaderboard.forEach(entry => {
      users[entry.user_id || entry.userId] = entry.points || 0;
    });
    
    setCachedData(cacheKey, users);
    return users;
  } catch (e) {
    console.error('Error fetching community users:', e);
    announceToScreenReader('Failed to load leaderboard');
    // Fallback to mock data if API fails
    setCachedData(cacheKey, mockCommunityUsers);
    return mockCommunityUsers;
  }
}

async function saveCommunityQuestion(questionData) {
  try {
    // Use mock data in development mode
    if (MOCK_MODE) {
      console.log('Mock mode: Saving question', questionData);
      console.log('Current profile:', currentProfile);
      
      const newQuestion = {
        id: mockCommunityQuestions.length > 0 ? Math.max(...mockCommunityQuestions.map(q => q.id)) + 1 : 1,
        text: questionData.text || questionData.content,
        user: { 
          full_name: currentProfile.full_name || 'Anonymous User', 
          profile_picture: currentProfile.profile_picture || 'Layer_1.svg' 
        },
        upvotes: 0,
        comments: [],
        created_at: new Date().toISOString()
      };
      
      mockCommunityQuestions.unshift(newQuestion); // Add to beginning
      
      // Update user points
      const userEmail = currentProfile.email || 'current_user@example.com';
      mockCommunityUsers[userEmail] = (mockCommunityUsers[userEmail] || 0) + 2; // 2 points for posting
      
      // Invalidate cache
      cache.delete('community-questions');
      cache.delete('community-users');
      announceToScreenReader('Question posted successfully');
      console.log('Mock mode: Question saved successfully', newQuestion);
      return newQuestion;
    }
    
    const token = localStorage.getItem('token');
    if (!token) throw new Error('Authentication required');
    
    const data = await apiCall('community/questions/', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}` },
      body: JSON.stringify(questionData)
    });
    
    // Invalidate cache
    cache.delete('community-questions');
    announceToScreenReader('Question posted successfully');
    return data;
  } catch (e) {
    console.error('Error saving community question:', e);
    announceToScreenReader('Failed to post question');
    throw e;
  }
}

async function toggleQuestionUpvote(questionId) {
  try {
    const token = localStorage.getItem('token');
    if (!token) throw new Error('Authentication required');
    
    // Use mock data in development mode
    if (MOCK_MODE) {
      const question = mockCommunityQuestions.find(q => q.id == questionId);
      if (question) {
        question.upvotes = (question.upvotes || 0) + 1;
        
        // Update user points
        const userEmail = currentProfile.email || 'current_user@example.com';
        mockCommunityUsers[userEmail] = (mockCommunityUsers[userEmail] || 0) + 1; // 1 point for upvoting
        
        // Invalidate cache
        cache.delete('community-questions');
        cache.delete('community-users');
        announceToScreenReader('Vote updated');
        return { upvotes: question.upvotes };
      }
    }
    
    const data = await apiCall(`community/questions/${questionId}/upvote/`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    // Invalidate cache
    cache.delete('community-questions');
    announceToScreenReader('Vote updated');
    return data;
  } catch (e) {
    console.error('Error toggling upvote:', e);
    announceToScreenReader('Failed to update vote');
    throw e;
  }
}

async function addQuestionComment(questionId, commentText) {
  try {
    const token = localStorage.getItem('token');
    if (!token) throw new Error('Authentication required');
    
    // Use mock data in development mode
    if (MOCK_MODE) {
      const question = mockCommunityQuestions.find(q => q.id == questionId);
      if (question) {
        const newComment = {
          id: Math.max(...(question.comments.map(c => c.id) || [0])) + 1,
          text: commentText,
          user: { 
            full_name: currentProfile.full_name || 'Anonymous User', 
            profile_picture: currentProfile.profile_picture || 'Layer_1.svg' 
          },
          created_at: new Date().toISOString()
        };
        
        question.comments.push(newComment);
        
        // Update user points
        const userEmail = currentProfile.email || 'current_user@example.com';
        mockCommunityUsers[userEmail] = (mockCommunityUsers[userEmail] || 0) + 1; // 1 point for commenting
        
        // Invalidate cache
        cache.delete('community-questions');
        cache.delete('community-users');
        announceToScreenReader('Comment added successfully');
        return newComment;
      }
    }
    
    const data = await apiCall(`community/questions/${questionId}/comments/`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({ text: commentText })
    });
    
    // Invalidate cache
    cache.delete('community-questions');
    announceToScreenReader('Comment added successfully');
    return data;
  } catch (e) {
    console.error('Error adding comment:', e);
    announceToScreenReader('Failed to add comment');
    throw e;
  }
}

// Enhanced Performance Monitoring
class PerformanceMonitor {
  constructor() {
    this.metrics = new Map();
    this.startTime = performance.now();
  }
  
  mark(name) {
    this.metrics.set(name, performance.now());
  }
  
  measure(name, startMark) {
    const endTime = performance.now();
    const startTime = this.metrics.get(startMark) || this.startTime;
    const duration = endTime - startTime;
    console.log(`${name}: ${duration.toFixed(2)}ms`);
    return duration;
  }
  
  trackUserAction(action, data = {}) {
    const timestamp = new Date().toISOString();
    const sessionData = {
      action,
      timestamp,
      user: getCurrentUser(),
      url: window.location.hash,
      ...data
    };
    
    // Store in localStorage for offline analytics
    const analytics = JSON.parse(localStorage.getItem('user_analytics') || '[]');
    analytics.push(sessionData);
    
    // Keep only last 100 entries to prevent storage overflow
    if (analytics.length > 100) {
      analytics.splice(0, analytics.length - 100);
    }
    
    localStorage.setItem('user_analytics', JSON.stringify(analytics));
    
    // Send to analytics endpoint if available
    this.sendAnalytics(sessionData);
  }
  
  async sendAnalytics(data) {
    try {
      // Only send if user is logged in and has consented
      if (isLoggedIn() && localStorage.getItem('analytics_consent') === 'true') {
        await fetch(`${baseURL}analytics/track/`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(data)
        });
      }
    } catch (e) {
      // Silently fail for analytics
      console.debug('Analytics tracking failed:', e);
    }
  }
  
  getEngagementMetrics() {
    const analytics = JSON.parse(localStorage.getItem('user_analytics') || '[]');
    const sessionStart = Date.now() - (30 * 60 * 1000); // Last 30 minutes
    const recentActions = analytics.filter(a => new Date(a.timestamp) > sessionStart);
    
    return {
      totalActions: analytics.length,
      recentActions: recentActions.length,
      mostVisitedSections: this.getMostVisitedSections(analytics),
      averageSessionTime: this.calculateAverageSessionTime(analytics)
    };
  }
  
  getMostVisitedSections(analytics) {
    const sections = {};
    analytics.forEach(a => {
      const section = a.url.split('#')[1] || 'home';
      sections[section] = (sections[section] || 0) + 1;
    });
    return Object.entries(sections)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 5);
  }
  
  calculateAverageSessionTime(analytics) {
    if (analytics.length < 2) return 0;
    const sessions = [];
    let sessionStart = null;
    
    analytics.forEach(action => {
      if (action.action === 'page_view') {
        if (sessionStart) {
          sessions.push(new Date(action.timestamp) - new Date(sessionStart));
        }
        sessionStart = action.timestamp;
      }
    });
    
    return sessions.length > 0 
      ? sessions.reduce((sum, time) => sum + time, 0) / sessions.length / 1000 / 60 // Convert to minutes
      : 0;
  }
}

const performanceMonitor = new PerformanceMonitor();

// Enhanced User Engagement Tracking
const trackPageView = (page) => {
  performanceMonitor.trackUserAction('page_view', { page });
};

const trackButtonClick = (buttonName, context = {}) => {
  performanceMonitor.trackUserAction('button_click', { buttonName, ...context });
};

const trackFormSubmission = (formName, success = true) => {
  performanceMonitor.trackUserAction('form_submission', { formName, success });
};

const trackSearchQuery = (query, resultsCount = 0) => {
  performanceMonitor.trackUserAction('search', { query, resultsCount });
};

// Enhanced Notification System
class NotificationManager {
  constructor() {
    this.container = document.getElementById('notification-container');
    this.notifications = new Map();
    this.offlineIndicator = document.getElementById('offline-indicator');
    this.setupOfflineDetection();
  }
  
  show(title, message, type = 'info', duration = 5000, actions = []) {
    const id = Date.now() + Math.random();
    const notification = this.createNotification(id, title, message, type, duration, actions);
    
    this.container.appendChild(notification);
    this.notifications.set(id, notification);
    
    // Trigger animation
    requestAnimationFrame(() => {
      notification.classList.add('show');
    });
    
    // Auto remove
    if (duration > 0) {
      setTimeout(() => this.remove(id), duration);
    }
    
    // Track notification
    performanceMonitor.trackUserAction('notification_shown', { type, title });
    
    return id;
  }
  
  createNotification(id, title, message, type, duration, actions) {
    const notification = document.createElement('div');
    notification.className = `toast-notification ${type}`;
    notification.setAttribute('role', 'alert');
    notification.setAttribute('aria-live', 'polite');
    
    const iconMap = {
      success: '✓',
      error: '✕',
      warning: '⚠',
      info: 'ℹ'
    };
    
    notification.innerHTML = `
      <div class="toast-icon">${iconMap[type] || 'ℹ'}</div>
      <div class="toast-content">
        <div class="toast-title">${title}</div>
        ${message ? `<div class="toast-message">${message}</div>` : ''}
      </div>
      <button class="toast-close" aria-label="Close notification">×</button>
      ${duration > 0 ? '<div class="toast-progress"></div>' : ''}
    `;
    
    // Add event listeners
    const closeBtn = notification.querySelector('.toast-close');
    closeBtn.addEventListener('click', () => this.remove(id));
    
    // Add keyboard support
    notification.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') this.remove(id);
    });
    
    return notification;
  }
  
  remove(id) {
    const notification = this.notifications.get(id);
    if (notification) {
      notification.classList.remove('show');
      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
        this.notifications.delete(id);
      }, 400);
    }
  }
  
  clear() {
    this.notifications.forEach((notification, id) => {
      this.remove(id);
    });
  }
  
  success(title, message, duration = 4000) {
    return this.show(title, message, 'success', duration);
  }
  
  error(title, message, duration = 6000) {
    return this.show(title, message, 'error', duration);
  }
  
  warning(title, message, duration = 5000) {
    return this.show(title, message, 'warning', duration);
  }
  
  info(title, message, duration = 4000) {
    return this.show(title, message, 'info', duration);
  }
  
  setupOfflineDetection() {
    const updateOnlineStatus = () => {
      if (navigator.onLine) {
        this.offlineIndicator.classList.remove('show');
        if (this.wasOffline) {
          this.success('Back Online', 'Your connection has been restored');
          this.wasOffline = false;
        }
      } else {
        this.offlineIndicator.classList.add('show');
        this.wasOffline = true;
      }
    };
    
    window.addEventListener('online', updateOnlineStatus);
    window.addEventListener('offline', updateOnlineStatus);
    updateOnlineStatus(); // Initial check
  }
}

// Enhanced Search System with Suggestions
class SearchManager {
  constructor() {
    this.searchData = new Map();
    this.setupSearch();
  }
  
  setupSearch() {
    const searchInput = document.getElementById('header-search-input');
    const searchContainer = document.querySelector('.search-container');
    
    if (searchInput && searchContainer) {
      // Create suggestions container
      const suggestions = document.createElement('div');
      suggestions.className = 'search-suggestions';
      suggestions.id = 'search-suggestions';
      searchContainer.appendChild(suggestions);
      
      // Debounced search
      const debouncedSearch = debounce((query) => {
        this.showSuggestions(query, suggestions);
      }, 300);
      
      searchInput.addEventListener('input', (e) => {
        const query = e.target.value.trim();
        if (query.length > 1) {
          debouncedSearch(query);
        } else {
          this.hideSuggestions(suggestions);
        }
      });
      
      // Keyboard navigation
      searchInput.addEventListener('keydown', (e) => {
        this.handleKeyNavigation(e, suggestions);
      });
      
      // Hide suggestions when clicking outside
      document.addEventListener('click', (e) => {
        if (!searchContainer.contains(e.target)) {
          this.hideSuggestions(suggestions);
        }
      });
    }
  }
  
  async showSuggestions(query, container) {
    try {
      const suggestions = await this.getSuggestions(query);
      this.renderSuggestions(suggestions, container, query);
      container.classList.add('show');
    } catch (e) {
      console.error('Error getting suggestions:', e);
    }
  }
  
  async getSuggestions(query) {
    // Mock suggestions - replace with actual API call
    const mockSuggestions = [
      { text: 'JavaScript Fundamentals', category: 'Track', icon: '📚' },
      { text: 'React Development', category: 'Track', icon: '📚' },
      { text: 'Python Basics', category: 'Language', icon: '🐍' },
      { text: 'Web Development', category: 'Track', icon: '🌐' },
      { text: 'Data Structures', category: 'Topic', icon: '🔧' }
    ];
    
    return mockSuggestions.filter(s => 
      s.text.toLowerCase().includes(query.toLowerCase())
    ).slice(0, 5);
  }
  
  renderSuggestions(suggestions, container, query) {
    container.innerHTML = suggestions.map(suggestion => `
      <div class="search-suggestion" data-text="${suggestion.text}">
        <span class="suggestion-icon">${suggestion.icon}</span>
        <span class="suggestion-text">${this.highlightMatch(suggestion.text, query)}</span>
        <span class="suggestion-category">${suggestion.category}</span>
      </div>
    `).join('');
    
    // Add click handlers
    container.querySelectorAll('.search-suggestion').forEach(item => {
      item.addEventListener('click', () => {
        const text = item.dataset.text;
        document.getElementById('header-search-input').value = text;
        this.hideSuggestions(container);
        this.performSearch(text);
      });
    });
  }
  
  highlightMatch(text, query) {
    const regex = new RegExp(`(${query})`, 'gi');
    return text.replace(regex, '<strong>$1</strong>');
  }
  
  hideSuggestions(container) {
    container.classList.remove('show');
  }
  
  handleKeyNavigation(e, container) {
    const suggestions = container.querySelectorAll('.search-suggestion');
    const current = container.querySelector('.search-suggestion.highlighted');
    let index = current ? Array.from(suggestions).indexOf(current) : -1;
    
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        index = Math.min(index + 1, suggestions.length - 1);
        this.highlightSuggestion(suggestions, index);
        break;
      case 'ArrowUp':
        e.preventDefault();
        index = Math.max(index - 1, 0);
        this.highlightSuggestion(suggestions, index);
        break;
      case 'Enter':
        e.preventDefault();
        if (current) {
          current.click();
        } else {
          this.performSearch(e.target.value);
        }
        break;
      case 'Escape':
        this.hideSuggestions(container);
        break;
    }
  }
  
  highlightSuggestion(suggestions, index) {
    suggestions.forEach((s, i) => {
      s.classList.toggle('highlighted', i === index);
    });
  }
  
  performSearch(query) {
    trackSearchQuery(query);
    // Implement actual search functionality
    console.log('Performing search for:', query);
  }
}

// Initialize enhanced systems
const notificationManager = new NotificationManager();
const searchManager = new SearchManager();

// Enhanced global notification functions
window.showNotification = (title, message, type = 'info') => {
  return notificationManager.show(title, message, type);
};

window.showSuccess = (title, message) => {
  return notificationManager.success(title, message);
};

window.showError = (title, message) => {
  return notificationManager.error(title, message);
};

window.showWarning = (title, message) => {
  return notificationManager.warning(title, message);
};

function getCurrentUser() {
  return currentProfile.full_name || 'Guest';
}

function getCurrentUserAvatar() {
  return currentProfile.profile_picture || APP_LOGO;
}

function getUserBadge(points) {
  if (points >= 100) return '🏆 Master';
  if (points >= 50) return '🥇 Expert';
  if (points >= 20) return '🥈 Learner';
  if (points >= 10) return '🥉 Newbie';
  return '';
}

function formatTimeAgo(timestamp) {
  const now = new Date();
  const diff = now - new Date(timestamp);
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (days > 0) return `${days}d ago`;
  if (hours > 0) return `${hours}h ago`;
  if (minutes > 0) return `${minutes}m ago`;
  return 'Just now';
}

function isLoggedIn() {
  // In mock mode, allow posting without authentication for testing
  if (MOCK_MODE) {
    return true;
  }
  return !!localStorage.getItem('token');
}

function getCurrentUserId() {
  // Use email as unique user id
  return currentProfile.email || null;
}

function getProfileInfo(userId) {
  // For API-based system, we'll get profile info from the question/comment data itself
  // This is a fallback for when profile info isn't embedded
  if (userId === currentProfile.email) {
    return {
      name: currentProfile.full_name || 'User',
      avatar: currentProfile.profile_picture || APP_LOGO
    };
  }
  return { name: 'User', avatar: APP_LOGO };
}

async function renderCommunityQuestions() {
  try {
    let questions = await getCommunityQuestions();
    
    // Sort: by upvotes desc, then timestamp desc
    questions = questions.slice().sort((a, b) => {
      if ((b.upvotes || 0) !== (a.upvotes || 0)) return (b.upvotes || 0) - (a.upvotes || 0);
      return new Date(b.created_at || b.timestamp) - new Date(a.created_at || a.timestamp);
    });
    
    // Filter by search if needed
    const searchInput = document.getElementById('community-search-input');
    let searchTerm = searchInput ? searchInput.value.trim().toLowerCase() : '';
    if (searchTerm) {
      questions = questions.filter(q => (q.text || q.content || '').toLowerCase().includes(searchTerm));
    }
    
    const container = document.getElementById('questions-list');
    container.innerHTML = '';
    
    questions.slice(0, COMMUNITY_QUESTIONS_PAGE_SIZE).forEach((q, index) => {
      const userName = q.user_name || q.author_name || getProfileInfo(q.user_id || q.userId).name;
      const userAvatar = q.user_avatar || q.author_avatar || getProfileInfo(q.user_id || q.userId).avatar;
      const questionText = q.text || q.content || '';
      const questionId = q.id;
      const timestamp = q.created_at || q.timestamp;
      const upvotes = q.upvotes || 0;
      const isUpvoted = q.is_upvoted || false;
      const commentsCount = q.comments_count || (q.comments ? q.comments.length : 0);
      
      const postCard = document.createElement('div');
      postCard.className = 'post-card';
      
      // SVG icons
      const upvoteIcon = `<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M10 4L4 12H16L10 4Z" fill="#3B82F6"/></svg>`;
      const commentIcon = `<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 3H17V15H5L3 17V3Z" stroke="#3B82F6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
      const disabled = !isLoggedIn() ? 'disabled' : '';
      
      postCard.innerHTML = `
        <div class="post-header">
          <div class="user-avatar">
            <img src="${userAvatar}" alt="${userName}" class="${!userAvatar || userAvatar === APP_LOGO ? 'default-avatar' : ''}">
          </div>
          <div class="post-user-info">
            <h4 class="post-username">${userName}</h4>
            <span class="post-time">${formatTimeAgo(timestamp)}</span>
          </div>
        </div>
        <div class="post-content">${questionText}</div>
        <div class="post-actions-bar">
          <button class="post-action ${isUpvoted ? 'active' : ''}" onclick="toggleUpvote(${questionId})" ${disabled} title="Upvote">
            ${upvoteIcon}
            <span>${upvotes}</span>
          </button>
          <button class="post-action" onclick="toggleComments(${questionId})" ${disabled} title="Comment">
            ${commentIcon}
            <span>${commentsCount}</span>
          </button>
        </div>
        <div class="comments-section" id="comments-${questionId}" style="display: none;">
          <div class="comments-list" id="comments-list-${questionId}">
            ${q.comments ? renderComments(q.comments) : ''}
          </div>
          <div class="add-comment">
            <input type="text" placeholder="Write a comment..." id="comment-input-${questionId}" ${disabled}>
            <button onclick="addComment(${questionId})" ${disabled}>Comment</button>
          </div>
        </div>
      `;
      container.appendChild(postCard);
    });
    
    if (!isLoggedIn()) {
      const msg = document.createElement('div');
      msg.style.color = '#fff';
      msg.style.textAlign = 'center';
      msg.style.marginTop = '1rem';
      msg.textContent = 'Login to post, upvote, or comment.';
      container.prepend(msg);
    }
  } catch (e) {
    console.error('Error rendering community questions:', e);
    const container = document.getElementById('questions-list');
    container.innerHTML = '<div style="color: #fff; text-align: center; padding: 2rem;">Failed to load questions. Please try again later.</div>';
  }
}

function renderComments(comments) {
  if (!comments || !comments.length) return '';
  return comments.map(comment => {
    const userName = comment.user_name || comment.author_name || 'User';
    const userAvatar = comment.user_avatar || comment.author_avatar || APP_LOGO;
    const commentText = comment.text || comment.content || '';
    const timestamp = comment.created_at || comment.timestamp;
    
    return `
      <div class="comment">
        <div class="user-avatar">
          <img src="${userAvatar}" alt="${userName}" class="${!userAvatar || userAvatar === APP_LOGO ? 'default-avatar' : ''}">
        </div>
        <div class="comment-content">
          <div class="comment-header">
            <span class="comment-username">${userName}</span>
            <span class="comment-time">${formatTimeAgo(timestamp)}</span>
          </div>
          <div class="comment-text">${commentText}</div>
        </div>
      </div>
    `;
  }).join('');
}

function toggleComments(questionId) {
  const commentsSection = document.getElementById(`comments-${questionId}`);
  if (commentsSection) {
    commentsSection.style.display = commentsSection.style.display === 'none' ? 'block' : 'none';
  }
}

async function addComment(questionId) {
  if (!isLoggedIn()) {
    showMessage('Please login to comment.');
    return;
  }
  
  try {
    const input = document.getElementById(`comment-input-${questionId}`);
    const text = input.value.trim();
    if (!text) return;
    
    await addQuestionComment(questionId, text);
    input.value = '';
    await renderCommunityQuestions(); // Refresh to show new comment
    
    // Keep comments section open
    const commentsSection = document.getElementById(`comments-${questionId}`);
    if (commentsSection) {
      commentsSection.style.display = 'block';
    }
  } catch (e) {
    console.error('Error adding comment:', e);
    showMessage('Failed to add comment. Please try again.');
  }
}

async function toggleUpvote(questionId) {
  if (!isLoggedIn()) {
    showMessage('Please login to upvote.');
    return;
  }
  
  try {
    await toggleQuestionUpvote(questionId);
    await renderCommunityQuestions(); // Refresh to show updated upvote count
  } catch (e) {
    console.error('Error toggling upvote:', e);
    showMessage('Failed to upvote. Please try again.');
  }
}

async function addCommunityQuestion(text) {
  console.log('addCommunityQuestion called with text:', text);
  console.log('isLoggedIn():', isLoggedIn());
  console.log('MOCK_MODE:', MOCK_MODE);
  
  if (!isLoggedIn()) {
    showMessage('Please login to post.');
    return;
  }
  
  try {
    const questionData = {
      text: text,
      content: text // Some APIs might expect 'content' instead of 'text'
    };
    
    console.log('Calling saveCommunityQuestion with:', questionData);
    await saveCommunityQuestion(questionData);
    
    console.log('saveCommunityQuestion successful, refreshing UI');
    await renderCommunityQuestions(); // Refresh to show new question
    await renderLeaderboard(); // Update leaderboard
    
    showMessage('Question posted successfully!', null, 'success');
  } catch (e) {
    console.error('Error adding community question:', e);
    console.error('Error details:', e.message, e.stack);
    showMessage('Failed to post question. Please try again.', null, 'error');
  }
}

async function renderLeaderboard() {
  try {
    const users = await getCommunityUsers();
    const leaderboard = Object.entries(users)
      .map(([userId, points]) => ({ userId, points }))
      .sort((a, b) => b.points - a.points)
      .slice(0, COMMUNITY_LEADERBOARD_PAGE_SIZE);
    
    const list = document.getElementById('leaderboard-list');
    list.innerHTML = '';
    
    leaderboard.forEach((entry, index) => {
      const { name, avatar } = getProfileInfo(entry.userId);
      const li = document.createElement('li');
      li.innerHTML = `
        <span class="leaderboard-rank">#${index + 1}</span>
        <div class="leaderboard-user">
          <div class="leaderboard-avatar">
            <img src="${avatar}" alt="${name}" class="${!avatar || avatar === APP_LOGO ? 'default-avatar' : ''}">
          </div>
          <span class="leaderboard-name">${name}</span>
        </div>
        <span class="leaderboard-badge">${getUserBadge(entry.points)}</span>
        <span class="leaderboard-points">${entry.points} pts</span>
      `;
      list.appendChild(li);
    });
  } catch (e) {
    console.error('Error rendering leaderboard:', e);
    const list = document.getElementById('leaderboard-list');
    list.innerHTML = '<li style="color: #fff; text-align: center;">Failed to load leaderboard</li>';
  }
}

// On load, fetch user profile for name and avatar
async function fetchCurrentProfile() {
  const token = localStorage.getItem('token');
  
  // In mock mode, use a default profile for testing
  if (MOCK_MODE && !token) {
    currentProfile = { 
      full_name: 'Demo User', 
      profile_picture: APP_LOGO, 
      email: 'demo@devguide.help' 
    };
    setPostFormUser();
    updateCommunityFormState();
    updateHeader(currentProfile);
    // Show user menu in mock mode
    document.getElementById('user-menu').classList.remove('hidden');
    // Show user links, hide guest links
    document.getElementById('user-links').classList.remove('hidden');
    document.getElementById('guest-links').classList.add('hidden');
    return;
  }
  
  if (!token) {
    currentProfile = { full_name: 'Guest', profile_picture: APP_LOGO, email: null };
    setPostFormUser();
    updateCommunityFormState();
    updateHeader(currentProfile);
    // Hide user menu when not logged in
    document.getElementById('user-menu').classList.add('hidden');
    // Show guest links, hide user links
    document.getElementById('guest-links').classList.remove('hidden');
    document.getElementById('user-links').classList.add('hidden');
    return;
  }
  try {
    const res = await fetch(`${baseURL}auth/profile/`, { headers: { 'Authorization': `Bearer ${token}` } });
    if (res.ok) {
      const data = await res.json();
      currentProfile = {
        full_name: data.full_name || 'Guest',
        profile_picture: data.profile_picture || APP_LOGO,
        email: data.email || null
      };
      // Show user menu when logged in
      document.getElementById('user-menu').classList.remove('hidden');
      updateHeader(currentProfile);
      // Update community profile for this user
      updateCommunityProfile(currentProfile.email, currentProfile.full_name, currentProfile.profile_picture);
      // Show user links, hide guest links
      document.getElementById('user-links').classList.remove('hidden');
      document.getElementById('guest-links').classList.add('hidden');
    } else {
      currentProfile = { full_name: 'Guest', profile_picture: APP_LOGO, email: null };
      // Hide user menu on auth error
      document.getElementById('user-menu').classList.add('hidden');
      updateHeader(currentProfile);
      // Show guest links, hide user links
      document.getElementById('guest-links').classList.remove('hidden');
      document.getElementById('user-links').classList.add('hidden');
    }
  } catch {
    currentProfile = { full_name: 'Guest', profile_picture: APP_LOGO, email: null };
    // Hide user menu on error
    document.getElementById('user-menu').classList.add('hidden');
    updateHeader(currentProfile);
    // Show guest links, hide user links
    document.getElementById('guest-links').classList.remove('hidden');
    document.getElementById('user-links').classList.add('hidden');
  }
  setPostFormUser();
  updateCommunityFormState();
}

function setPostFormUser() {
  const avatar = document.getElementById('post-user-avatar');
  if (avatar) {
    avatar.src = getCurrentUserAvatar();
    avatar.className = avatar.src === APP_LOGO ? 'default-avatar' : '';
  }
}

function updateCommunityFormState() {
  const form = document.getElementById('community-post-form');
  if (!form) return;
  if (isLoggedIn() && currentProfile.email) {
    form.style.opacity = '1';
    form.querySelectorAll('input,button').forEach(el => el.disabled = false);
  } else {
    form.style.opacity = '0.5';
    form.querySelectorAll('input,button').forEach(el => el.disabled = true);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  // Add scroll behavior for all navigation links
  document.querySelectorAll('a[href^="#"]').forEach(link => {
    link.addEventListener('click', () => {
      window.scrollTo({
        top: 0,
        behavior: 'instant'
      });
    });
  });

  window.addEventListener('hashchange', () => {
    window.scrollTo({
      top: 0,
      behavior: 'instant'
    });
    router();
  });

  // Initial route and scroll to top
  router();
  window.scrollTo({
    top: 0,
    behavior: 'instant'
  });
  initForms();
  initAuth();
  // Intercept nav link clicks to update SPA route without scrolling
  document.querySelectorAll('.header-nav a[href^="#"]').forEach(link => {
    if (link.id === 'logout-btn') return;
    link.addEventListener('click', e => {
      e.preventDefault();
      const hash = link.getAttribute('href');
      location.hash = hash;
    });
  });
  // User menu dropdown toggle
  const userButton = document.querySelector('.user-button');
  const userDropdown = document.getElementById('user-dropdown');
  if (userButton) {
    userButton.addEventListener('click', e => {
      e.stopPropagation();
      userDropdown.classList.toggle('open');
    });
    // Close when clicking outside
    document.addEventListener('click', e => {
      if (!userButton.contains(e.target)) userDropdown.classList.remove('open');
    });
  }
  // Floating chatbot button click opens chat modal
  const chatFloatBtn = document.getElementById('chatbot-float');
  if (chatFloatBtn) {
    // Add hover typing indicator bubble
    const chatBubble = document.createElement('div');
    chatBubble.className = 'chatbot-bubble hidden';
    chatBubble.innerHTML = '<span class="dot"></span><span class="dot"></span><span class="dot"></span>';
    chatFloatBtn.appendChild(chatBubble);
    chatFloatBtn.addEventListener('mouseenter', () => {
      const token = localStorage.getItem('token');
      if (token) chatBubble.classList.remove('hidden');
    });
    chatFloatBtn.addEventListener('mouseleave', () => {
      chatBubble.classList.add('hidden');
    });
    chatFloatBtn.addEventListener('click', () => {
      const token = localStorage.getItem('token');
      if (!token) {
        showMessage('Please login to use the chatbot', () => { location.hash = 'login'; });
        return;
      }
      const chatModal = document.getElementById('chat-modal');
      chatModal.classList.remove('hidden');
      
      // Show welcome message if not shown yet in this session
      if (!chatbotModalWelcomeShown) {
        const chatDiv = document.getElementById('chat-modal-messages');
        // Clear any existing messages first
        chatDiv.innerHTML = '';
        showChatbotWelcome(chatDiv, true);
      }
    });
  }
  // Setup no-results modal functionality
  const modal = document.getElementById('no-results-modal');
  const closeBtn = modal.querySelector('.modal-close');
  const chatBtn = document.getElementById('modal-chatbot-btn');
  // Close handlers
  closeBtn.addEventListener('click', () => modal.classList.add('hidden'));
  modal.addEventListener('click', e => { if (e.target === modal) modal.classList.add('hidden'); });
  // Chatbot button
  chatBtn.addEventListener('click', () => {
    const token = localStorage.getItem('token');
    if (!token) {
      modal.classList.add('hidden');
      showMessage('Please login to use the chatbot', () => { location.hash = 'login'; });
      return;
    }
    modal.classList.add('hidden');
    location.hash = 'chatbot';
  });
  // Setup chat-modal functionality
  const chatModal = document.getElementById('chat-modal');
  const chatClose = chatModal.querySelector('.modal-close-chat');
  chatClose.addEventListener('click', () => chatModal.classList.add('hidden'));
  chatModal.addEventListener('click', e => { if (e.target === chatModal) chatModal.classList.add('hidden'); });
  // Expand chat modal to full page chat section
  const chatExpandBtn = document.getElementById('chat-modal-expand');
  if (chatExpandBtn) {
    chatExpandBtn.addEventListener('click', () => {
      // Copy messages from modal to full page if expanding
      const modalMessages = document.getElementById('chat-modal-messages');
      const pageMessages = document.getElementById('chatbot-messages');
      if (modalMessages && pageMessages && modalMessages.innerHTML.trim()) {
        pageMessages.innerHTML = modalMessages.innerHTML;
        // Mark page welcome as shown since we're copying from modal
        chatbotPageWelcomeShown = true;
      }
      
      chatModal.classList.add('hidden');
      location.hash = 'chatbot';
    });
  }
  // Toggle header search input and redirect
  const headerSearchToggle = document.getElementById('header-search-toggle');
  const headerSearchInput = document.getElementById('header-search-input');
  const doHeaderSearch = () => {
    const q = headerSearchInput.value.trim();
    if (!q) return;
    document.getElementById('search-query').value = q;
    location.hash = 'search';
  };
  headerSearchToggle.addEventListener('click', e => {
    e.preventDefault();
    headerSearchInput.classList.toggle('hidden');
    if (!headerSearchInput.classList.contains('hidden')) headerSearchInput.focus();
  });
  headerSearchInput.addEventListener('keydown', e => {
    if (e.key === 'Enter') { e.preventDefault(); doHeaderSearch(); }
  });
  // Trigger search when pressing Enter in main search input
  const mainSearchInput = document.getElementById('search-query');
  if (mainSearchInput) {
    mainSearchInput.addEventListener('keydown', e => {
      if (e.key === 'Enter') {
        e.preventDefault();
        document.getElementById('search-form').dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
      }
    });
  }
  // Message modal setup
  const messageModal = document.getElementById('message-modal');
  const messageText = document.getElementById('message-modal-text');
  const messageCloseBtn = messageModal.querySelector('.modal-close');
  function showMessage(msg, callback) {
    messageText.textContent = msg;
    messageModal.classList.remove('hidden');
    messageCloseBtn.onclick = () => {
      messageModal.classList.add('hidden');
      if (callback) callback();
    };
    messageModal.onclick = (e) => { if (e.target === messageModal) {
      messageModal.classList.add('hidden');
      if (callback) callback();
    }};
  }
  // Community Q&A logic
  const communityForm = document.getElementById('community-post-form');
  if (communityForm) {
    communityForm.addEventListener('submit', async e => {
      e.preventDefault();
      const input = document.getElementById('community-question');
      const text = input.value.trim();
      if (text) {
        await addCommunityQuestion(text);
        input.value = '';
      }
    });
  }
  
  // Test mock system first
  testMockSystem();
  
  // Initialize community features - ensure profile is loaded first
  (async () => {
    await fetchCurrentProfile();
  renderCommunityQuestions();
  renderLeaderboard();
    updateCommunityFormState();
    
    // Test again after profile fetch
    console.log('🔄 After fetchCurrentProfile:');
    console.log('currentProfile:', currentProfile);
    console.log('isLoggedIn():', isLoggedIn());
  })();

  // Instant preview for profile picture
  const picInput = document.getElementById('profile-picture');
  if (picInput) {
    picInput.addEventListener('change', function() {
      const file = this.files[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
          document.getElementById('profile-avatar-preview').src = e.target.result;
        };
        reader.readAsDataURL(file);
      }
    });
  }

  // Read More for questions
  const readMoreQuestions = document.getElementById('read-more-questions');
  if (readMoreQuestions) {
    readMoreQuestions.addEventListener('click', () => {
      location.hash = 'all-questions';
    });
  }
  // Read More for leaderboard
  const readMoreLeaderboard = document.getElementById('read-more-leaderboard');
  if (readMoreLeaderboard) {
    readMoreLeaderboard.addEventListener('click', () => {
      location.hash = 'all-leaderboard';
    });
  }
  // Search for main community page
  const communitySearchForm = document.getElementById('community-search-form');
  if (communitySearchForm) {
    communitySearchForm.addEventListener('submit', async e => {
      e.preventDefault();
      await renderCommunityQuestions();
    });
    const searchInput = document.getElementById('community-search-input');
    if (searchInput) {
      searchInput.addEventListener('input', async () => await renderCommunityQuestions());
    }
  }
  // Search for all-questions page
  const allQuestionsSearchForm = document.getElementById('all-questions-search-form');
  if (allQuestionsSearchForm) {
    allQuestionsSearchForm.addEventListener('submit', async e => {
      e.preventDefault();
      await renderAllQuestions();
    });
    const searchInput = document.getElementById('all-questions-search-input');
    if (searchInput) {
      searchInput.addEventListener('input', async () => await renderAllQuestions());
    }
  }

  // Initialize scroll to top button
  const scrollToTopBtn = document.getElementById('scroll-to-top');

  // Show/hide scroll to top button based on scroll position
  window.addEventListener('scroll', () => {
    if (window.scrollY > 300) {
      scrollToTopBtn.classList.remove('hidden');
    } else {
      scrollToTopBtn.classList.add('hidden');
    }
  });

  // Scroll to top when button is clicked
  scrollToTopBtn.addEventListener('click', () => {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  });
});

function router() {
  const token = localStorage.getItem('token');
  let hash = location.hash.slice(1) || 'tracks';
  
  // Mobile device detection and redirection
  if (isMobileDevice() && !shouldSkipMobileRedirect()) {
    // Only redirect on first visit or if explicitly navigating to home/tracks
    if (isFirstVisit() || hash === 'tracks' || hash === '') {
      // Don't redirect if user is already on mobile-app page or auth pages
      if (hash !== 'mobile-app' && hash !== 'login' && hash !== 'register' && hash !== 'reset-password' && hash !== 'reset-password-confirm') {
        console.log('🔄 Mobile device detected, redirecting to mobile app page');
        location.hash = 'mobile-app';
        return;
      }
    }
  }
  
  if (hash === 'chatbot' && !token) {
    showMessage('Please login to use the chatbot', () => { location.hash = 'login'; });
    return;
  }
  document.querySelectorAll('.section').forEach(sec => sec.classList.remove('active'));
  const active = document.getElementById(hash);
  if (active) {
    active.classList.add('active');
    // Scroll to top immediately when changing routes
    window.scrollTo({
      top: 0,
      behavior: 'instant'
    });
  }
  if (hash === 'languages') {
    if (pendingTrackId) {
      loadTrackLanguages(pendingTrackId);
      pendingTrackId = null;
    } else {
      loadLanguages();
    }
  } else if (hash === 'terms') {
    if (pendingLanguageName) {
      loadLanguageTerms(pendingLanguageName);
      pendingLanguageName = null;
    }
  }
  if (hash === 'tracks') loadTracks();
  if (hash === 'my-tracks') loadMyTracks();
  if (hash === 'my-languages') loadMyLanguages();
  if (hash === 'profile') loadProfile();
  if (hash === 'community') {
    renderCommunityQuestions();
    renderLeaderboard();
  }
  if (hash === 'all-questions') {
    renderAllQuestions();
  }
  if (hash === 'all-leaderboard') {
    renderAllLeaderboard();
  }
  if (hash === 'upcoming') {
    initUpcomingFeatures();
  }
  if (hash === 'mobile-app') {
    initMobileAppPage();
  }
  if (hash === 'chatbot') {
    // Show welcome message if not shown yet in this session
    if (!chatbotPageWelcomeShown) {
      setTimeout(() => {
        const chatDiv = document.getElementById('chatbot-messages');
        if (chatDiv) {
          // Clear any existing messages first
          chatDiv.innerHTML = '';
          showChatbotWelcome(chatDiv, false);
        }
      }, 100); // Small delay to ensure elements are loaded
    }
  }
  // Auto-run search when navigating to search page
  if (hash === 'search') {
    const form = document.getElementById('search-form');
    if (form) form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
  }
}

function initForms() {
  // Register
  document.getElementById('register-form').addEventListener('submit', async e => {
    e.preventDefault();
    const full_name = document.getElementById('register-fullname').value;
    const email = document.getElementById('register-email').value;
    const password = document.getElementById('register-password').value;
    const password_confirm = document.getElementById('register-password-confirm').value;
    const phone_number = document.getElementById('register-phone').value;
    const res = await fetch(`${baseURL}auth/register/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ full_name, email, password, password_confirm, phone_number })
    });
    if (res.ok) {
      showMessage('Registered! Please login.', () => { location.hash = 'login'; });
    } else {
      const err = await res.json();
      showMessage(formatErrors(err));
    }
  });

  // Login
  document.getElementById('login-form').addEventListener('submit', async e => {
    e.preventDefault();
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;
    const remember_me = document.getElementById('login-remember').checked;
    const payload = { email, password };
    if (remember_me) payload.remember_me = true;
    const res = await fetch(`${baseURL}auth/login/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (res.ok) {
      const data = await res.json();
      localStorage.setItem('token', data.tokens.access);
      localStorage.setItem('refresh_token', data.tokens.refresh);
      await afterAuthChange();
      location.hash = 'tracks';
    } else {
      const err = await res.json();
      showMessage(formatErrors(err));
    }
  });

  // Reset password request
  document.getElementById('reset-password-form').addEventListener('submit', async e => {
    e.preventDefault();
    const email = document.getElementById('reset-email').value;
    const res = await fetch(`${baseURL}auth/reset-password/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email })
    });
    if (res.ok) {
      showMessage('OTP sent to email.', () => { location.hash = 'reset-password-confirm'; });
    } else {
      const err = await res.json();
      showMessage(JSON.stringify(err));
    }
  });

  // Confirm reset
  document.getElementById('reset-confirm-form').addEventListener('submit', async e => {
    e.preventDefault();
    const otp = document.getElementById('reset-otp').value;
    const new_password = document.getElementById('reset-new-password').value;
    const res = await fetch(`${baseURL}auth/verify-otp/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ otp, new_password })
    });
    if (res.ok) {
      showMessage('Password reset! Please login.', () => { location.hash = 'login'; });
    } else {
      const err = await res.json();
      showMessage(JSON.stringify(err));
    }
  });

  // Chatbot
  document.getElementById('chatbot-form').addEventListener('submit', async e => {
    e.preventDefault();
    const msgInput = document.getElementById('chatbot-input');
    const msg = msgInput.value;
    const token = localStorage.getItem('token');
    const chatDiv = document.getElementById('chatbot-messages');
    // Append user message
    chatDiv.innerHTML += `<div class="message user">${msg}</div>`;
    // Create typing indicator
    const typingEl = document.createElement('div');
    typingEl.className = 'message bot typing';
    typingEl.innerHTML = '<span class="dot"></span><span class="dot"></span><span class="dot"></span>';
    chatDiv.appendChild(typingEl);
    // Clear input
    msgInput.value = '';
    // Show icon typing bubble during bot response
    const bubble = document.querySelector('.chatbot-bubble');
    if (bubble) bubble.classList.remove('hidden');
    // Send to API
    const res = await fetch(`${baseURL}chatbot/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({ message: msg })
    });
    const data = await res.json();
    // Remove typing indicator
    typingEl.remove();
    // Hide icon typing bubble after response
    if (bubble) bubble.classList.add('hidden');
    // Render bot response with markdown formatting
    const botHTML = marked.parse(data.response || '');
    chatDiv.innerHTML += `<div class="message bot">${botHTML}</div>`;
    // Auto-scroll
    chatDiv.scrollTop = chatDiv.scrollHeight;
  });

  // Chat modal form submission
  document.getElementById('chat-modal-form').addEventListener('submit', async e => {
    e.preventDefault();
    const msgInput2 = document.getElementById('chat-modal-input');
    const msg2 = msgInput2.value;
    const token2 = localStorage.getItem('token');
    const chatDiv2 = document.getElementById('chat-modal-messages');
    // Append user message
    chatDiv2.innerHTML += `<div class="message user">${msg2}</div>`;
    // Typing indicator
    const typingEl2 = document.createElement('div');
    typingEl2.className = 'message bot typing';
    typingEl2.innerHTML = '<span class="dot"></span><span class="dot"></span><span class="dot"></span>';
    chatDiv2.appendChild(typingEl2);
    // Clear input
    msgInput2.value = '';
    // Show icon typing bubble during bot response
    const bubble2 = document.querySelector('.chatbot-bubble');
    if (bubble2) bubble2.classList.remove('hidden');
    // Send to API
    const res2 = await fetch(`${baseURL}chatbot/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token2}` },
      body: JSON.stringify({ message: msg2 })
    });
    const data2 = await res2.json();
    // Remove typing indicator and render bot response
    typingEl2.remove();
    // Hide icon typing bubble after response
    if (bubble2) bubble2.classList.add('hidden');
    const botHTML2 = marked.parse(data2.response || '');
    chatDiv2.innerHTML += `<div class="message bot">${botHTML2}</div>`;
    chatDiv2.scrollTop = chatDiv2.scrollHeight;
  });

  // Profile update
  document.getElementById('profile-form').addEventListener('submit', async e => {
    e.preventDefault();
    const token = localStorage.getItem('token');
    const full_name = document.getElementById('profile-fullname').value;
    const email = document.getElementById('profile-email').value;
    const phone_number = document.getElementById('profile-phone').value;
    const new_password = document.getElementById('profile-new-password').value;
    // Update fields
    await fetch(`${baseURL}auth/update-name/`, { method: 'PATCH', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }, body: JSON.stringify({ full_name }) });
    await fetch(`${baseURL}auth/update-email/`, { method: 'PATCH', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }, body: JSON.stringify({ email }) });
    await fetch(`${baseURL}auth/update-phone/`, { method: 'PATCH', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }, body: JSON.stringify({ phone_number }) });
    if (new_password) {
      await fetch(`${baseURL}auth/update-password/`, { method: 'PATCH', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }, body: JSON.stringify({ new_password }) });
    }
    const picFile = document.getElementById('profile-picture').files[0];
    if (picFile) {
      const formData = new FormData();
      formData.append('profile_picture', picFile);
      const res = await fetch(`${baseURL}auth/update-profile-picture/`, {
        method: 'PATCH',
        headers: { 'Authorization': `Bearer ${token}` },
        body: formData
      });
      if (res.ok) {
        // Update preview immediately
        const reader = new FileReader();
        reader.onload = function(e) {
          document.getElementById('profile-avatar-preview').src = e.target.result;
          // Also update header avatar if present
          const userPic = document.getElementById('user-pic');
          if (userPic) updateUserPicture(userPic, e.target.result);
        };
        reader.readAsDataURL(picFile);
        // Re-fetch profile to update everywhere
        await fetchCurrentProfile();
      }
    } else {
      await fetchCurrentProfile();
    }
    showMessage('Profile updated');
  });

  // Search
  document.getElementById('search-form').addEventListener('submit', async e => {
    e.preventDefault();
    
    // Hide no-results modal and show loading
    document.getElementById('search-no-results').classList.add('hidden');
    const loadingDiv = document.querySelector('.search-loading');
    loadingDiv.classList.remove('hidden');
    
    const q = document.getElementById('search-query').value;
    const category = document.getElementById('search-category').value;
    const sortBy = document.getElementById('search-sort').value;
    
    console.log('Search params:', { query: q, category, sortBy });
    
    // Update search stats
    document.getElementById('search-results-count').textContent = '...';
    document.getElementById('search-categories-count').textContent = '...';
    
    const token = localStorage.getItem('token');
    const params = new URLSearchParams();
    params.append('query', q);
    if (category !== 'all') params.append('category', category);
    if (sortBy !== 'relevance') params.append('sort', sortBy);
    
    const headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
    };
    if (token) headers['Authorization'] = `Bearer ${token}`;
    
    try {
    const res = await fetch(`${baseURL}search/`, {
      method: 'POST',
      headers,
      body: params.toString()
    });
      
    const data = await res.json();
      loadingDiv.classList.add('hidden');
      
      const container = document.getElementById('search-results-grid');
    container.innerHTML = '';

      let totalResults = 0;
      let categoriesFound = 0;
      
      // Helper function to create enhanced search result cards
      const createSearchCard = (item, type) => {
        const card = document.createElement('div');
        card.className = 'search-result-card';
        
        let logoSrc = 'Layer_1.svg';
        let title = '';
        let description = '';
        let tags = [];
        let actions = '';
        
        switch (type) {
                     case 'track':
             logoSrc = item.icon ? `${baseURL.replace('/api/', '')}${item.icon}` : 'Layer_1.svg';
             title = item.name;
             description = item.description;
             tags = item.difficulty ? [item.difficulty] : [];
            actions = `
              <button class="search-result-btn search-result-btn-primary" onclick="location.hash='tracks'">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M9 11H5a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7a2 2 0 0 0-2-2h-4"/>
                  <path d="M9 7V4a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v3"/>
                </svg>
                Learn More
              </button>
              <button class="search-result-btn search-result-btn-secondary" onclick="toggleTrackFavorite(${item.id}, this)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <polygon points="12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26 12,2"/>
                </svg>
                Favorite
              </button>
            `;
            break;
                     case 'language':
             logoSrc = item.icon ? `${baseURL.replace('/api/', '')}${item.icon}` : 'Layer_1.svg';
             title = item.name;
             description = item.description;
             tags = item.category ? [item.category] : [];
            actions = `
              <button class="search-result-btn search-result-btn-primary" onclick="pendingLanguageName='${item.name}'; location.hash='terms'">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                  <polyline points="14,2 14,8 20,8"/>
                  <line x1="16" y1="13" x2="8" y2="13"/>
                  <line x1="16" y1="17" x2="8" y2="17"/>
                </svg>
                View Terms
              </button>
              <button class="search-result-btn search-result-btn-secondary" onclick="toggleLanguageFavorite(${item.id}, this)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <polygon points="12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26 12,2"/>
                </svg>
                Favorite
              </button>
            `;
            break;
          case 'term':
            logoSrc = 'Layer_1.svg';
            title = item.term;
            description = item.description;
            tags = item.difficulty ? [item.difficulty] : [];
            actions = `
              <button class="search-result-btn search-result-btn-primary" onclick="window.open('${item.link}', '_blank')">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/>
                  <polyline points="15,3 21,3 21,9"/>
                  <line x1="10" y1="14" x2="21" y2="3"/>
                </svg>
                Read More
              </button>
              <button class="search-result-btn search-result-btn-secondary" onclick="navigator.share ? navigator.share({title: '${title}', url: '${item.link}'}) : copyToClipboard('${item.link}')">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/>
                  <polyline points="16,6 12,2 8,6"/>
                  <line x1="12" y1="2" x2="12" y2="15"/>
                </svg>
                Share
              </button>
            `;
            break;
        }
        
        card.innerHTML = `
          <div class="search-result-header">
            <div class="search-result-logo">
              <img src="${logoSrc}" alt="${title} Logo" onerror="this.src='Layer_1.svg'">
            </div>
            <div class="search-result-header-content">
              <h3 class="search-result-title">${title}</h3>
              <span class="search-result-type">${type}</span>
          </div>
          </div>
          <p class="search-result-description">${description}</p>
          ${tags.length ? `<div class="search-result-tags">${tags.map(tag => `<span class="search-result-tag">${tag}</span>`).join('')}</div>` : ''}
          <div class="search-result-actions">
            ${actions}
          </div>
        `;
        
        return card;
      };
      
      // Collect all results for sorting
      let allResults = [];
      
      // Collect tracks
      if (data.tracks && data.tracks.results.length) {
        data.tracks.results.forEach(track => {
          allResults.push({ ...track, type: 'track' });
        });
        categoriesFound++;
      }
      
      // Collect languages
      if (data.languages && data.languages.results.length) {
        data.languages.results.forEach(lang => {
          allResults.push({ ...lang, type: 'language' });
        });
        categoriesFound++;
      }
      
      // Collect terms
      if (data.terms && data.terms.results.length) {
        data.terms.results.forEach(term => {
          allResults.push({ ...term, type: 'term' });
        });
        categoriesFound++;
      }
      
      // Apply frontend sorting if needed
      const currentSort = document.getElementById('search-sort').value;
      allResults = sortSearchResults(allResults, currentSort);
      
      // Apply category filtering if needed
      const currentCategory = document.getElementById('search-category').value;
      if (currentCategory !== 'all') {
        allResults = allResults.filter(item => {
          if (currentCategory === 'tracks') return item.type === 'track';
          if (currentCategory === 'languages') return item.type === 'language';
          if (currentCategory === 'terms') return item.type === 'term';
          return true;
        });
      }
      
      totalResults = allResults.length;
      
      // Render filtered and sorted results
      allResults.forEach(item => {
        container.appendChild(createSearchCard(item, item.type));
      });
      
      // Update stats
      document.getElementById('search-results-count').textContent = totalResults;
      document.getElementById('search-categories-count').textContent = categoriesFound;
      
      // Show filter indicators
      updateFilterIndicators(currentCategory, currentSort);
      
      // Show no results if needed
      if (totalResults === 0) {
        document.getElementById('search-no-results').classList.remove('hidden');
      } else {
        document.getElementById('search-no-results').classList.add('hidden');
      }
      
      // Add staggered animation to results
      const cards = container.querySelectorAll('.search-result-card');
      cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        setTimeout(() => {
          card.style.transition = 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)';
          card.style.opacity = '1';
          card.style.transform = 'translateY(0)';
        }, index * 100);
      });
      
      // Track search
      trackSearchQuery(q, totalResults);
      
    } catch (error) {
      console.error('Search error:', error);
      loadingDiv.classList.add('hidden');
      document.getElementById('search-no-results').classList.remove('hidden');
      document.getElementById('search-results-count').textContent = '0';
      document.getElementById('search-categories-count').textContent = '0';
    }
  });
}

// Favorite toggles via API
async function toggleLanguageFavorite(id, btn) {
  const token = localStorage.getItem('token');
  if (!token) {
    showMessage('Please login to add favorites', null, 'warning');
    return;
  }
  
  const isFav = btn.classList.contains('favorited');
  const action = isFav ? 'remove' : 'add';
  const method = isFav ? 'DELETE' : 'POST';
  const url = `${baseURL}languages/favorite/${action}/${id}/`;
  
  try {
    const res = await fetch(url, {
      method,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (res.ok) {
      btn.classList.toggle('favorited');
      const svg = btn.querySelector('svg');
      if (btn.classList.contains('favorited')) {
        if (svg) svg.setAttribute('fill', 'currentColor');
        showMessage('Added to favorites!', null, 'success');
      } else {
        if (svg) svg.setAttribute('fill', 'none');
        showMessage('Removed from favorites', null, 'info');
      }
    } else {
      const errorData = await res.json().catch(() => ({}));
      console.error('API Error:', res.status, errorData);
      showMessage('Failed to update favorite', null, 'error');
    }
  } catch (error) {
    console.error('Network error:', error);
    showMessage('Network error occurred', null, 'error');
  }
}

async function toggleTrackFavorite(id, btn) {
  const token = localStorage.getItem('token');
  if (!token) {
    showMessage('Please login to add favorites', null, 'warning');
    return;
  }
  
  const isFav = btn.classList.contains('favorited');
  const action = isFav ? 'remove' : 'add';
  const method = isFav ? 'DELETE' : 'POST';
  const url = `${baseURL}tracks/favorite/${action}/${id}/`;
  
  try {
    const res = await fetch(url, {
      method,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (res.ok) {
      btn.classList.toggle('favorited');
      const svg = btn.querySelector('svg');
      if (btn.classList.contains('favorited')) {
        if (svg) svg.setAttribute('fill', 'currentColor');
        showMessage('Added to favorites!', null, 'success');
      } else {
        if (svg) svg.setAttribute('fill', 'none');
        showMessage('Removed from favorites', null, 'info');
      }
    } else {
      const errorData = await res.json().catch(() => ({}));
      console.error('API Error:', res.status, errorData);
      showMessage('Failed to update favorite', null, 'error');
    }
  } catch (error) {
    console.error('Network error:', error);
    showMessage('Network error occurred', null, 'error');
  }
}

// Load lists
async function loadLanguages() {
  const token = localStorage.getItem('token');
  const headers = token ? { 'Authorization': `Bearer ${token}` } : {};
  const res = await fetch(`${baseURL}languages/`, { headers });
  if (!res.ok) { console.error('Failed to fetch languages:', res.status); return; }
  const data = await res.json();
  const langs = Array.isArray(data) ? data : (data.results || []);
  const languagesList = document.getElementById('languages-list');
  languagesList.innerHTML = '';

  // Load favorite language IDs if logged in
  let favLangIds = [];
  if (token) {
    try {
      const favRes = await fetch(`${baseURL}languages/favorites/`, { method: 'GET', headers });
      if (favRes.ok) {
        const favData = await favRes.json();
        const favs = Array.isArray(favData) ? favData : (favData.results || []);
        favLangIds = favs.map(l => l.id);
      }
    } catch (e) {
      console.error('Error fetching favorite languages:', e);
    }
  }

  langs.forEach(lang => {
    const langCard = document.createElement('div');
    langCard.className = 'track-card';
    langCard.innerHTML = `
      <div class="track-header">
        <div class="track-icon has-icon">
          <img src="${lang.icon || 'Layer_1.svg'}" alt="${lang.name} Logo">
        </div>
        <button class="favorite-btn" data-lang-id="${lang.id}" aria-label="Favorite">★</button>
      </div>
      <div class="track-content">
        <h3 class="track-title">${lang.name}</h3>
        <p class="track-description">${lang.description}</p>
        <div class="track-actions">
          <button class="explore-btn">Explore Terms</button>
        </div>
      </div>
    `;
    langCard.querySelector('.explore-btn').addEventListener('click', () => {
      pendingLanguageName = lang.name;
      document.getElementById('terms-heading').textContent = lang.name;
      location.hash = 'terms';
    });
    // Favorite handling
    const favBtnLang = langCard.querySelector('.favorite-btn');
    // Mark as favorited if in user's favorites
    if (favLangIds.includes(lang.id)) favBtnLang.classList.add('favorited');
    favBtnLang.addEventListener('click', () => toggleLanguageFavorite(lang.id, favBtnLang));
    languagesList.appendChild(langCard);
  });

  document.querySelectorAll('#languages-list .track-card').forEach(card => {
    card.addEventListener('mouseenter', () => { card.style.transform = 'translateY(-10px)'; });
    card.addEventListener('mouseleave', () => { card.style.transform = 'translateY(0)'; });
  });
}

async function loadTracks() {
  const token = localStorage.getItem('token');
  const headers = token ? { 'Authorization': `Bearer ${token}` } : {};
  const res = await fetch(`${baseURL}tracks/`, { headers });
  if (!res.ok) { console.error('Failed to fetch tracks:', res.status); return; }
  const data = await res.json();
  const tracks = Array.isArray(data) ? data : (data.results || []);
  const tracksList = document.getElementById('tracks-list');
  tracksList.innerHTML = '';

  // Load favorite track IDs if logged in
  let favIds = [];
  if (token) {
    try {
      const favRes = await fetch(`${baseURL}tracks/favorites/`, { method: 'GET', headers });
      if (favRes.ok) {
        const favData = await favRes.json();
        const favs = Array.isArray(favData) ? favData : (favData.results || []);
        favIds = favs.map(t => t.id);
      }
    } catch (e) {
      console.error('Error fetching favorite tracks:', e);
    }
  }

  tracks.forEach(track => {
    const trackCard = document.createElement('div');
    trackCard.className = 'track-card';
    trackCard.innerHTML = `
      <div class="track-header">
        <div class="track-icon has-icon">
          <img src="${track.icon || 'Layer_1.svg'}" alt="${track.name} Logo">
        </div>
        <button class="favorite-btn" data-track-id="${track.id}" aria-label="Favorite">★</button>
        ${track.difficulty ? `<span class="track-badge">${track.difficulty}</span>` : ''}
      </div>
      <div class="track-content">
        <h3 class="track-title">${track.name}</h3>
        <p class="track-description">${track.description}</p>
        <div class="track-stats">
          ${track.duration ? `<span class="track-stat">${track.duration}</span>` : ''}
          ${track.lessons ? `<span class="track-stat">${track.lessons} lessons</span>` : ''}
        </div>
        <div class="track-actions">
          <button class="explore-btn">Explore</button>
        </div>
      </div>
    `;
    trackCard.querySelector('.explore-btn').addEventListener('click', () => {
      pendingTrackId = track.id;
      location.hash = 'languages';
    });
    // Favorite handling
    const favBtnTrack = trackCard.querySelector('.favorite-btn');
    // Mark as favorited if in user's favorites
    if (favIds.includes(track.id)) favBtnTrack.classList.add('favorited');
    favBtnTrack.addEventListener('click', () => toggleTrackFavorite(track.id, favBtnTrack));
    tracksList.appendChild(trackCard);
  });

  document.querySelectorAll('.track-card').forEach(card => {
    card.addEventListener('mouseenter', () => { card.style.transform = 'translateY(-10px)'; });
    card.addEventListener('mouseleave', () => { card.style.transform = 'translateY(0)'; });
  });
}

// Load user's favorited tracks
async function loadMyTracks() {
  const token = localStorage.getItem('token');
  if (!token) {
    showMessage('Please login to view your favorite tracks.');
    return;
  }
  try {
    const res = await fetch(`${baseURL}tracks/favorites/`, {
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    if (!res.ok) {
      showMessage('Failed to load favorite tracks.');
      return;
    }
    const data = await res.json();
    const favs = Array.isArray(data) ? data : (data.results || []);
    const container = document.getElementById('my-tracks-list');
    container.innerHTML = '';
    if (!favs.length) {
      container.innerHTML = '<p>No favorite tracks found.</p>';
      return;
    }
    favs.forEach(track => {
      const trackCard = document.createElement('div');
      trackCard.className = 'track-card';
      trackCard.innerHTML = `
        <div class="track-header">
          <div class="track-icon has-icon">
            <img src="${track.icon || 'Layer_1.svg'}" alt="${track.name} Logo">
          </div>
          <button class="favorite-btn" data-track-id="${track.id}" aria-label="Favorite">★</button>
          ${track.difficulty ? `<span class="track-badge">${track.difficulty}</span>` : ''}
        </div>
        <div class="track-content">
          <h3 class="track-title">${track.name}</h3>
          <p class="track-description">${track.description}</p>
          <div class="track-stats">
            ${track.duration ? `<span class="track-stat">${track.duration}</span>` : ''}
            ${track.lessons ? `<span class="track-stat">${track.lessons} lessons</span>` : ''}
          </div>
          <div class="track-actions">
            <button class="explore-btn">Explore</button>
          </div>
        </div>
      `;
      trackCard.querySelector('.explore-btn').addEventListener('click', () => {
        pendingTrackId = track.id;
        location.hash = 'languages';
      });
      const favBtn = trackCard.querySelector('.favorite-btn');
      favBtn.classList.add('favorited');
      favBtn.addEventListener('click', () => toggleTrackFavorite(track.id, favBtn));
      container.appendChild(trackCard);
    });
  } catch (e) {
    console.error('Error loading favorite tracks:', e);
    showMessage('Network error loading favorites.');
  }
}

// Load user's favorited languages
async function loadMyLanguages() {
  const token = localStorage.getItem('token');
  if (!token) {
    showMessage('Please login to view your favorite languages.');
    return;
  }
  try {
    const res = await fetch(`${baseURL}languages/favorites/`, {
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    if (!res.ok) {
      showMessage('Failed to load favorite languages.');
      return;
    }
    const data = await res.json();
    const favs = Array.isArray(data) ? data : (data.results || []);
    const container = document.getElementById('my-languages-list');
    container.innerHTML = '';
    if (!favs.length) {
      container.innerHTML = '<p>No favorite languages found.</p>';
      return;
    }
    favs.forEach(lang => {
      const langCard = document.createElement('div');
      langCard.className = 'track-card';
      langCard.innerHTML = `
        <div class="track-header">
          <div class="track-icon has-icon">
            <img src="${lang.icon || 'Layer_1.svg'}" alt="${lang.name} Logo">
          </div>
          <button class="favorite-btn" data-lang-id="${lang.id}" aria-label="Favorite">★</button>
        </div>
        <div class="track-content">
          <h3 class="track-title">${lang.name}</h3>
          <p class="track-description">${lang.description}</p>
          <div class="track-actions">
            <button class="explore-btn">Explore Terms</button>
          </div>
        </div>
      `;
      langCard.querySelector('.explore-btn').addEventListener('click', () => {
        pendingLanguageName = lang.name;
        document.getElementById('terms-heading').textContent = lang.name;
        location.hash = 'terms';
      });
      const favBtn = langCard.querySelector('.favorite-btn');
      favBtn.classList.add('favorited');
      favBtn.addEventListener('click', () => toggleLanguageFavorite(lang.id, favBtn));
      container.appendChild(langCard);
    });
  } catch (e) {
    console.error('Error loading favorite languages:', e);
    showMessage('Network error loading favorites.');
  }
}

async function loadProfile() {
  const token = localStorage.getItem('token');
  const res = await fetch(`${baseURL}auth/profile/`, { headers: { 'Authorization': `Bearer ${token}` } });
  const data = await res.json();
  document.getElementById('profile-fullname').value = data.full_name || '';
  document.getElementById('profile-email').value = data.email || '';
  document.getElementById('profile-phone').value = data.phone_number || '';
  // Set avatar preview to current profile picture or fallback
  document.getElementById('profile-avatar-preview').src = data.profile_picture || APP_LOGO;
}

// Initialize authentication state and header display
async function initAuth() {
  const token = localStorage.getItem('token');
  if (!token) return;
  const res = await fetch(`${baseURL}auth/profile/`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  if (res.ok) {
    const profile = await res.json();
    updateHeader(profile);
  } else {
    localStorage.removeItem('token');
  }
}

function updateHeader(profile) {
  const userMenu = document.getElementById('user-menu');
  if (!profile.email) {
    // Guest
    userMenu.classList.remove('hidden');
    document.getElementById('guest-links').classList.remove('hidden');
    document.getElementById('user-links').classList.add('hidden');
    document.getElementById('user-name').textContent = 'Guest';
    const userPic = document.getElementById('user-pic');
    updateUserPicture(userPic, null);
    return;
  }
  // Logged in
  userMenu.classList.remove('hidden');
  document.getElementById('guest-links').classList.add('hidden');
  document.getElementById('user-links').classList.remove('hidden');
  // Show only first name in the topbar
  const firstName = profile.full_name ? profile.full_name.split(' ')[0] : 'User';
  document.getElementById('user-name').textContent = firstName;
  const userPic = document.getElementById('user-pic');
  updateUserPicture(userPic, profile.profile_picture);
  
  // Logout handler
  document.getElementById('logout-btn').addEventListener('click', async e => {
    e.preventDefault();
    const token = localStorage.getItem('token');
    await fetch(`${baseURL}auth/logout/`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    localStorage.removeItem('token');
    
    // Reset chatbot welcome message tracking
    chatbotModalWelcomeShown = false;
    chatbotPageWelcomeShown = false;
    
    // Clear chat messages
    const modalMessages = document.getElementById('chat-modal-messages');
    const pageMessages = document.getElementById('chatbot-messages');
    if (modalMessages) modalMessages.innerHTML = '';
    if (pageMessages) pageMessages.innerHTML = '';
    
    // Reset to guest state
    document.getElementById('user-name').textContent = 'Guest';
    const userPicElement = document.getElementById('user-pic');
    updateUserPicture(userPicElement, null);
    document.getElementById('user-links').classList.add('hidden');
    document.getElementById('guest-links').classList.remove('hidden');
    // Optionally close dropdown
    document.getElementById('user-dropdown').classList.remove('open');
    location.hash = 'login';
  });
}

// Helper function to update user picture (works for both img and div elements)
function updateUserPicture(element, imageUrl) {
  if (!element) return;
  
  if (imageUrl) {
    // User has a profile picture
    element.classList.remove('default-avatar');
    if (element.tagName === 'IMG') {
      element.src = imageUrl;
    } else {
      // It's a div, use background image
      element.style.backgroundImage = `url(${imageUrl})`;
      element.innerHTML = ''; // Clear any default content
    }
  } else {
    // Use default avatar
    element.classList.add('default-avatar');
    if (element.tagName === 'IMG') {
      element.src = APP_LOGO;
    } else {
      // It's a div, clear background and let CSS handle the default
      element.style.backgroundImage = '';
      element.innerHTML = ''; // CSS ::before will handle the emoji
    }
  }
}

async function loadTrackLanguages(trackId) {
  const token = localStorage.getItem('token');
  const headers = token ? { 'Authorization': `Bearer ${token}` } : {};
  const res = await fetch(`${baseURL}tracks/${trackId}/`, { headers });
  if (!res.ok) { console.error('Failed to load track details:', res.status); return; }
  const data = await res.json();
  const langs = data.languages || [];
  const languagesList = document.getElementById('languages-list');
  languagesList.innerHTML = '';

  langs.forEach(lang => {
    const langCard = document.createElement('div');
    langCard.className = 'track-card';
    langCard.innerHTML = `
      <div class="track-header">
        <div class="track-icon has-icon">
          <img src="${lang.icon || 'Layer_1.svg'}" alt="${lang.name} Logo">
        </div>
      </div>
      <div class="track-content">
        <h3 class="track-title">${lang.name}</h3>
        <p class="track-description">${lang.description}</p>
        <div class="track-actions">
          <button class="explore-btn">Explore Terms</button>
        </div>
      </div>
    `;
    langCard.querySelector('.explore-btn').addEventListener('click', () => {
      pendingLanguageName = lang.name;
      document.getElementById('terms-heading').textContent = lang.name;
      location.hash = 'terms';
    });
    languagesList.appendChild(langCard);
  });

  document.querySelectorAll('#languages-list .track-card').forEach(card => {
    card.addEventListener('mouseenter', () => { card.style.transform = 'translateY(-10px)'; });
    card.addEventListener('mouseleave', () => { card.style.transform = 'translateY(0)'; });
  });
}

// Load language-specific terms
async function loadLanguageTerms(languageName) {
  const token = localStorage.getItem('token');
  const headers = token ? { 'Authorization': `Bearer ${token}` } : {};
  
  try {
  const res = await fetch(`${baseURL}languages/${encodeURIComponent(languageName)}/terms/`, { headers });
    if (!res.ok) { 
      console.error('Failed to load terms:', res.status); 
      showTermsError('Failed to load terms. Please try again later.');
      return; 
    }
    
  const data = await res.json();
    currentTermsData = enhanceTermsData(data || []);
    filteredTermsData = [...currentTermsData];
    
    updateTermsStats();
    renderTerms();
    initializeTermsControls();
    
  } catch (error) {
    console.error('Error loading terms:', error);
    showTermsError('Failed to load terms. Please check your connection.');
  }
}

// Enhance terms data with additional properties for better UX
function enhanceTermsData(terms) {
  const difficulties = ['beginner', 'intermediate', 'advanced', 'expert'];
  const icons = ['📚', '🔧', '💡', '⚡', '🎯', '🔍', '🚀', '💻', '🎨', '🔐'];
  
  return terms.map((term, index) => ({
    ...term,
    id: index,
    difficulty: term.difficulty || difficulties[Math.floor(Math.random() * difficulties.length)],
    icon: term.icon || icons[index % icons.length],
    tags: term.tags || generateTermTags(term.term, term.description),
    importance: term.importance || Math.floor(Math.random() * 5) + 1,
    category: term.category || 'General'
  }));
}

// Generate relevant tags for terms
function generateTermTags(termName, description) {
  const commonTags = ['syntax', 'concept', 'method', 'property', 'function', 'class', 'variable', 'operator'];
  const tags = [];
  
  // Add tags based on term name and description
  if (termName.toLowerCase().includes('function')) tags.push('function');
  if (termName.toLowerCase().includes('class')) tags.push('class');
  if (termName.toLowerCase().includes('var') || termName.toLowerCase().includes('let') || termName.toLowerCase().includes('const')) tags.push('variable');
  if (description.toLowerCase().includes('syntax')) tags.push('syntax');
  if (description.toLowerCase().includes('method')) tags.push('method');
  
  // Add random tags if none were found
  while (tags.length < 2) {
    const randomTag = commonTags[Math.floor(Math.random() * commonTags.length)];
    if (!tags.includes(randomTag)) tags.push(randomTag);
  }
  
  return tags.slice(0, 3); // Limit to 3 tags
}

// Update terms statistics
function updateTermsStats() {
  const termsCountEl = document.getElementById('terms-count');
  const categoriesCountEl = document.getElementById('terms-categories');
  
  if (termsCountEl) termsCountEl.textContent = currentTermsData.length;
  
  if (categoriesCountEl) {
    const categories = [...new Set(currentTermsData.map(term => term.category))];
    categoriesCountEl.textContent = categories.length;
  }
}

// Initialize terms controls (search, filter, view toggle)
function initializeTermsControls() {
  const searchInput = document.getElementById('terms-search');
  const clearSearchBtn = document.getElementById('clear-terms-search');
  const sortSelect = document.getElementById('terms-sort');
  const gridViewBtn = document.getElementById('grid-view');
  const listViewBtn = document.getElementById('list-view');
  
  // Search functionality
  if (searchInput) {
    searchInput.addEventListener('input', debounce(handleTermsSearch, 300));
    searchInput.addEventListener('input', () => {
      if (clearSearchBtn) {
        clearSearchBtn.classList.toggle('show', searchInput.value.length > 0);
      }
    });
  }
  
  // Clear search
  if (clearSearchBtn) {
    clearSearchBtn.addEventListener('click', () => {
      if (searchInput) {
        searchInput.value = '';
        clearSearchBtn.classList.remove('show');
        handleTermsSearch();
      }
    });
  }
  
  // Sort functionality
  if (sortSelect) {
    sortSelect.addEventListener('change', handleTermsSort);
  }
  
  // View toggle
  if (gridViewBtn && listViewBtn) {
    gridViewBtn.addEventListener('click', () => setTermsView('grid'));
    listViewBtn.addEventListener('click', () => setTermsView('list'));
  }
}

// Handle terms search
function handleTermsSearch() {
  const searchInput = document.getElementById('terms-search');
  const query = searchInput ? searchInput.value.trim().toLowerCase() : '';
  
  if (!query) {
    filteredTermsData = [...currentTermsData];
  } else {
    filteredTermsData = currentTermsData.filter(term => 
      term.term.toLowerCase().includes(query) ||
      term.description.toLowerCase().includes(query) ||
      term.tags.some(tag => tag.toLowerCase().includes(query)) ||
      term.category.toLowerCase().includes(query)
    );
  }
  
  renderTerms();
}

// Handle terms sorting
function handleTermsSort() {
  const sortSelect = document.getElementById('terms-sort');
  const sortType = sortSelect ? sortSelect.value : 'alphabetical';
  
  switch (sortType) {
    case 'alphabetical':
      filteredTermsData.sort((a, b) => a.term.localeCompare(b.term));
      break;
    case 'reverse-alphabetical':
      filteredTermsData.sort((a, b) => b.term.localeCompare(a.term));
      break;
    case 'importance':
      filteredTermsData.sort((a, b) => b.importance - a.importance);
      break;
    case 'difficulty':
      const difficultyOrder = { beginner: 1, intermediate: 2, advanced: 3, expert: 4 };
      filteredTermsData.sort((a, b) => difficultyOrder[a.difficulty] - difficultyOrder[b.difficulty]);
      break;
  }
  
  renderTerms();
}

// Set terms view (grid or list)
function setTermsView(view) {
  currentTermsView = view;
  
  const gridBtn = document.getElementById('grid-view');
  const listBtn = document.getElementById('list-view');
  const termsList = document.getElementById('terms-list');
  
  if (gridBtn && listBtn) {
    gridBtn.classList.toggle('active', view === 'grid');
    listBtn.classList.toggle('active', view === 'list');
  }
  
  if (termsList) {
    termsList.className = view === 'grid' ? 'terms-grid' : 'terms-list';
  }
  
  renderTerms();
}

// Render terms with enhanced design
function renderTerms() {
  const termsList = document.getElementById('terms-list');
  const noResultsEl = document.getElementById('terms-no-results');
  
  if (!termsList) return;
  
  // Show loading state
  termsList.classList.add('loading');
  
  setTimeout(() => {
    termsList.innerHTML = '';
    termsList.classList.remove('loading');
    
    if (filteredTermsData.length === 0) {
      if (noResultsEl) noResultsEl.classList.remove('hidden');
      return;
    }
    
    if (noResultsEl) noResultsEl.classList.add('hidden');
    
    filteredTermsData.forEach((term, index) => {
      const termCard = createTermCard(term, index);
      termsList.appendChild(termCard);
    });
  }, 200);
}

// Create enhanced term card
function createTermCard(term, index) {
  const card = document.createElement('div');
  card.className = 'term-card';
  card.style.animationDelay = `${(index % 10) * 0.05 + 0.1}s`;
  
  const difficultyClass = term.difficulty || 'beginner';
  const isExpanded = false;
  
  card.innerHTML = `
    <div class="term-header">
      <div class="term-icon">${term.icon}</div>
      <div class="term-title-section">
        <h3 class="term-name">${escapeHtml(term.term)}</h3>
        <span class="term-difficulty ${difficultyClass}">${difficultyClass}</span>
          </div>
          </div>
    
    <div class="term-content">
      <p class="term-description">${escapeHtml(term.description)}</p>
      ${term.tags && term.tags.length > 0 ? `
        <div class="term-tags">
          ${term.tags.map(tag => `<span class="term-tag">${escapeHtml(tag)}</span>`).join('')}
        </div>
      ` : ''}
    </div>
    
    <div class="term-actions">
      <button class="term-expand-btn" onclick="toggleTermExpansion(this)" title="Show more">
        <span class="expand-text">Show more</span>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="6,9 12,15 18,9"/>
        </svg>
          </button>
      <a href="${term.link}" target="_blank" class="term-link" title="Learn more">
        Learn more
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/>
          <polyline points="15,3 21,3 21,9"/>
          <line x1="10" y1="14" x2="21" y2="3"/>
        </svg>
      </a>
        </div>
      `;
  
  return card;
}

// Toggle term card expansion
function toggleTermExpansion(button) {
  const card = button.closest('.term-card');
  const expandText = button.querySelector('.expand-text');
  const svg = button.querySelector('svg');
  
  if (card.classList.contains('term-expanded')) {
    card.classList.remove('term-expanded');
    expandText.textContent = 'Show more';
    svg.style.transform = 'rotate(0deg)';
  } else {
    card.classList.add('term-expanded');
    expandText.textContent = 'Show less';
    svg.style.transform = 'rotate(180deg)';
  }
}

// Show terms error message
function showTermsError(message) {
  const termsList = document.getElementById('terms-list');
  const noResultsEl = document.getElementById('terms-no-results');
  
  if (termsList) {
    termsList.innerHTML = `
      <div class="terms-error">
        <div class="error-icon">⚠️</div>
        <h3>Error Loading Terms</h3>
        <p>${message}</p>
        <button class="btn" onclick="location.reload()">Retry</button>
          </div>
    `;
  }
  
  if (noResultsEl) noResultsEl.classList.add('hidden');
}

// Utility function to escape HTML
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

// Initialize upcoming features page
function initUpcomingFeatures() {
  // Add progress bar animations
  const progressBars = document.querySelectorAll('.progress-bar-upcoming');
  progressBars.forEach(bar => {
    const width = bar.style.width;
    bar.style.width = '0%';
    setTimeout(() => {
      bar.style.width = width;
    }, 100);
  });

  // Add notification form functionality
  const notifyForm = document.querySelector('.notify-form');
  if (notifyForm) {
    const notifyBtn = notifyForm.querySelector('.notify-btn');
    const notifyInput = notifyForm.querySelector('.notify-input');
    
    notifyBtn.addEventListener('click', async (e) => {
      e.preventDefault();
      const email = notifyInput.value.trim();
      
      if (!email) {
        showMessage('Please enter your email address.');
        return;
      }
      
      if (!isValidEmail(email)) {
        showMessage('Please enter a valid email address.');
        return;
      }
      
      // Simulate API call for notifications
      notifyBtn.textContent = 'Subscribing...';
      notifyBtn.disabled = true;
      
      try {
        // You can implement actual API call here
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        showMessage('🎉 Thank you! You\'ll be notified when these features launch!');
        notifyInput.value = '';
        notifyBtn.textContent = '✓ Subscribed';
        
        setTimeout(() => {
          notifyBtn.textContent = 'Notify Me';
          notifyBtn.disabled = false;
        }, 3000);
        
      } catch (error) {
        showMessage('Something went wrong. Please try again.');
        notifyBtn.textContent = 'Notify Me';
        notifyBtn.disabled = false;
      }
    });
    
    // Handle Enter key
    notifyInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        notifyBtn.click();
      }
    });
  }

  // Add hover effects and interactions
  const upcomingCards = document.querySelectorAll('.upcoming-card');
  upcomingCards.forEach(card => {
    card.addEventListener('mouseenter', () => {
      const icon = card.querySelector('.upcoming-icon');
      if (icon) {
        icon.style.transform = 'scale(1.1) rotate(5deg)';
      }
    });
    
    card.addEventListener('mouseleave', () => {
      const icon = card.querySelector('.upcoming-icon');
      if (icon) {
        icon.style.transform = 'scale(1) rotate(0deg)';
      }
    });
  });

  // Feature tag interactions
  const featureTags = document.querySelectorAll('.feature-tag');
  featureTags.forEach(tag => {
    tag.addEventListener('click', () => {
      // Add a small pulse animation
      tag.style.transform = 'scale(1.1)';
      setTimeout(() => {
        tag.style.transform = 'scale(1)';
      }, 150);
    });
  });
}

// Email validation helper
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// Quick Reference Tab Functionality
function initializeQuickReference() {
  const tabButtons = document.querySelectorAll('.tab-button');
  const tabPanels = document.querySelectorAll('.tab-panel');
  
  if (tabButtons.length === 0 || tabPanels.length === 0) return;
  
  tabButtons.forEach(button => {
    button.addEventListener('click', (e) => {
      e.preventDefault();
      const targetTab = button.getAttribute('data-tab');
      
      // Remove active class from all buttons and panels
      tabButtons.forEach(btn => btn.classList.remove('active'));
      tabPanels.forEach(panel => panel.classList.remove('active'));
      
      // Add active class to clicked button and corresponding panel
      button.classList.add('active');
      const targetPanel = document.getElementById(targetTab);
      if (targetPanel) {
        targetPanel.classList.add('active');
      }
      
      // Add ripple effect
      const ripple = document.createElement('span');
      ripple.classList.add('ripple');
      ripple.style.cssText = `
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        transform: scale(0);
        animation: ripple 0.6s linear;
        pointer-events: none;
        left: 50%;
        top: 50%;
        width: 20px;
        height: 20px;
        margin-left: -10px;
        margin-top: -10px;
      `;
      
      button.style.position = 'relative';
      button.appendChild(ripple);
      
      setTimeout(() => {
        if (ripple.parentNode) {
          ripple.remove();
        }
      }, 600);
      
      // Track tab interaction
      if (typeof trackButtonClick === 'function') {
        trackButtonClick('quick-reference-tab', { tab: targetTab });
      }
    });
  });
}

// Initialize Quick Reference when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  // Initialize Quick Reference tabs with a small delay to ensure DOM is ready
  setTimeout(() => {
    initializeQuickReference();
  }, 100);
});

// =================================
// ENHANCED DESIGN FUNCTIONALITY
// =================================

// Enhanced Mouse Tracking for Cards
function initEnhancedInteractions() {
  // Add mouse tracking for upcoming cards
  const upcomingCards = document.querySelectorAll('.upcoming-card');
  upcomingCards.forEach(card => {
    card.addEventListener('mousemove', (e) => {
      const rect = card.getBoundingClientRect();
      const x = ((e.clientX - rect.left) / rect.width) * 100;
      const y = ((e.clientY - rect.top) / rect.height) * 100;
      card.style.setProperty('--mouse-x', `${x}%`);
      card.style.setProperty('--mouse-y', `${y}%`);
    });
  });

  // Add enhanced ripple effect for buttons
  const buttons = document.querySelectorAll('.btn, button');
  buttons.forEach(button => {
    button.addEventListener('click', (e) => {
      const ripple = document.createElement('span');
      const rect = button.getBoundingClientRect();
      const size = Math.max(rect.width, rect.height);
      const x = e.clientX - rect.left - size / 2;
      const y = e.clientY - rect.top - size / 2;
      
      ripple.style.cssText = `
        position: absolute;
        width: ${size}px;
        height: ${size}px;
        left: ${x}px;
        top: ${y}px;
        background: rgba(255, 255, 255, 0.3);
        border-radius: 50%;
        transform: scale(0);
        animation: ripple 0.6s linear;
        pointer-events: none;
      `;
      
      button.style.position = 'relative';
      button.style.overflow = 'hidden';
      button.appendChild(ripple);
      
      setTimeout(() => {
        ripple.remove();
      }, 600);
    });
  });
}

// Enhanced Scroll Animations
function initEnhancedScrollAnimations() {
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.animationPlayState = 'running';
        entry.target.classList.add('animate-in');
      }
    });
  }, observerOptions);

  // Observe all cards and sections
  const elementsToAnimate = document.querySelectorAll(`
    .track-card, .team-card, .upcoming-card, .post-card,
    .legal-section, .usage-item, .responsibility-card
  `);
  
  elementsToAnimate.forEach(el => {
    el.style.animationPlayState = 'paused';
    observer.observe(el);
  });
}

// Enhanced Form Validation with Visual Feedback
function initEnhancedFormValidation() {
  const inputs = document.querySelectorAll('input[type="email"], input[type="password"], input[type="text"], input[type="tel"]');
  
  inputs.forEach(input => {
    // Add real-time validation
    input.addEventListener('input', (e) => {
      const value = e.target.value;
      const type = e.target.type;
      
      // Remove previous validation classes
      input.classList.remove('valid', 'invalid');
      
      // Validate based on type
      let isValid = false;
      if (type === 'email') {
        isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
      } else if (type === 'password') {
        isValid = value.length >= 6;
      } else if (type === 'text' || type === 'tel') {
        isValid = value.length >= 2;
      }
      
      if (value) {
        input.classList.add(isValid ? 'valid' : 'invalid');
      }
    });
  });
}

// Enhanced Performance Monitoring
function initPerformanceEnhancements() {
  // Lazy load images
  const images = document.querySelectorAll('img[data-src]');
  const imageObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const img = entry.target;
        img.src = img.dataset.src;
        img.removeAttribute('data-src');
        imageObserver.unobserve(img);
      }
    });
  });
  
  images.forEach(img => imageObserver.observe(img));

  // Add performance metrics
  if ('performance' in window) {
    window.addEventListener('load', () => {
      setTimeout(() => {
        const perfData = performance.getEntriesByType('navigation')[0];
        console.log('Page Load Performance:', {
          loadTime: perfData.loadEventEnd - perfData.loadEventStart,
          domContentLoaded: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
          totalTime: perfData.loadEventEnd - perfData.fetchStart
        });
      }, 0);
    });
  }
}

// Enhanced Accessibility Features
function initAccessibilityEnhancements() {
  // Add keyboard navigation for cards
  const cards = document.querySelectorAll('.track-card, .team-card, .upcoming-card');
  cards.forEach(card => {
    card.setAttribute('tabindex', '0');
    card.setAttribute('role', 'article');
    
    card.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        card.click();
      }
    });
  });

  // Add ARIA labels for better screen reader support
  const buttons = document.querySelectorAll('.btn, button');
  buttons.forEach(button => {
    if (!button.getAttribute('aria-label') && !button.textContent.trim()) {
      button.setAttribute('aria-label', 'Button');
    }
  });

  // Enhanced focus management
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Tab') {
      document.body.classList.add('keyboard-navigation');
    }
  });

  document.addEventListener('mousedown', () => {
    document.body.classList.remove('keyboard-navigation');
  });
}

// Enhanced Error Handling with User-Friendly Messages
function initEnhancedErrorHandling() {
  window.addEventListener('error', (e) => {
    console.error('Global error:', e.error);
    
    // Show user-friendly error message
    if (window.notificationManager) {
      notificationManager.error(
        'Something went wrong',
        'We encountered an unexpected error. Please try refreshing the page.',
        8000
      );
    }
  });

  // Handle unhandled promise rejections
  window.addEventListener('unhandledrejection', (e) => {
    console.error('Unhandled promise rejection:', e.reason);
    
    if (window.notificationManager) {
      notificationManager.warning(
        'Connection Issue',
        'There seems to be a connectivity issue. Some features may not work properly.',
        6000
      );
    }
  });
}

// Enhanced Theme and Visual Effects
function initVisualEnhancements() {
  // Add dynamic background effects
  const decorCircles = document.querySelectorAll('.decor-circle');
  decorCircles.forEach((circle, index) => {
    circle.style.animationDelay = `${index * 0.5}s`;
    circle.style.animation = `float 6s ease-in-out infinite`;
  });

  // Add CSS for floating animation
  if (!document.querySelector('#dynamic-styles')) {
    const style = document.createElement('style');
    style.id = 'dynamic-styles';
    style.textContent = `
      @keyframes float {
        0%, 100% { transform: translateY(0px) rotate(0deg); }
        50% { transform: translateY(-20px) rotate(5deg); }
      }
      
      @keyframes ripple {
        to {
          transform: scale(4);
          opacity: 0;
        }
      }
      
      .keyboard-navigation *:focus {
        outline: 3px solid #4facfe !important;
        outline-offset: 2px !important;
      }
      
      input.valid {
        border-color: #56ab2f !important;
        box-shadow: 0 0 0 3px rgba(86, 171, 47, 0.2) !important;
      }
      
      input.invalid {
        border-color: #ff6b6b !important;
        box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.2) !important;
      }
    `;
    document.head.appendChild(style);
  }
}

// Initialize all enhancements
function initAllEnhancements() {
  // Wait for DOM to be ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      initAllEnhancements();
    });
    return;
  }

  try {
    initEnhancedInteractions();
    initEnhancedScrollAnimations();
    initEnhancedFormValidation();
    initPerformanceEnhancements();
    initAccessibilityEnhancements();
    initEnhancedErrorHandling();
    initVisualEnhancements();
    initSearchFilters();
    initSearchViewToggle();
    initChatbotHelpButton();
    
    console.log('✨ All design enhancements initialized successfully!');
  } catch (error) {
    console.error('Error initializing enhancements:', error);
  }
}

// Helper function for copying to clipboard
function copyToClipboard(text) {
  if (navigator.clipboard) {
    navigator.clipboard.writeText(text).then(() => {
      showMessage('Link copied to clipboard!', null, 'success');
    }).catch(() => {
      fallbackCopyToClipboard(text);
    });
  } else {
    fallbackCopyToClipboard(text);
  }
}

function fallbackCopyToClipboard(text) {
  const textArea = document.createElement('textarea');
  textArea.value = text;
  textArea.style.position = 'fixed';
  textArea.style.left = '-999999px';
  textArea.style.top = '-999999px';
  document.body.appendChild(textArea);
  textArea.focus();
  textArea.select();
  
  try {
    document.execCommand('copy');
    showMessage('Link copied to clipboard!', null, 'success');
  } catch (err) {
    showMessage('Failed to copy link', null, 'error');
  }
  
  document.body.removeChild(textArea);
}

// Initialize Search View Toggle and Controls
// Update filter indicators to show active filters
function updateFilterIndicators(category, sort) {
  const categorySelect = document.getElementById('search-category');
  const sortSelect = document.getElementById('search-sort');
  
  // Add visual indicator for active category filter
  if (categorySelect) {
    if (category !== 'all') {
      categorySelect.style.background = 'linear-gradient(135deg, rgba(59, 130, 246, 0.3) 0%, rgba(16, 185, 129, 0.3) 100%)';
      categorySelect.style.borderColor = 'rgba(59, 130, 246, 0.5)';
    } else {
      categorySelect.style.background = '';
      categorySelect.style.borderColor = '';
    }
  }
  
  // Add visual indicator for active sort filter
  if (sortSelect) {
    if (sort !== 'relevance') {
      sortSelect.style.background = 'linear-gradient(135deg, rgba(59, 130, 246, 0.3) 0%, rgba(16, 185, 129, 0.3) 100%)';
      sortSelect.style.borderColor = 'rgba(59, 130, 246, 0.5)';
    } else {
      sortSelect.style.background = '';
      sortSelect.style.borderColor = '';
    }
  }
  
  // Show filter status message
  const filterMessages = [];
  if (category !== 'all') {
    filterMessages.push(`Category: ${category}`);
  }
  if (sort !== 'relevance') {
    filterMessages.push(`Sort: ${sort.replace('-', ' ')}`);
  }
  
  if (filterMessages.length > 0) {
    console.log('Active filters:', filterMessages.join(', '));
  }
}

// Sort search results based on selected criteria
function sortSearchResults(results, sortBy) {
  const sortedResults = [...results];
  
  switch (sortBy) {
    case 'alphabetical':
      return sortedResults.sort((a, b) => {
        const nameA = (a.name || a.term || '').toLowerCase();
        const nameB = (b.name || b.term || '').toLowerCase();
        return nameA.localeCompare(nameB);
      });
      
    case 'reverse-alphabetical':
      return sortedResults.sort((a, b) => {
        const nameA = (a.name || a.term || '').toLowerCase();
        const nameB = (b.name || b.term || '').toLowerCase();
        return nameB.localeCompare(nameA);
      });
      
    case 'popularity':
      return sortedResults.sort((a, b) => {
        // Sort by type priority (tracks > languages > terms) then by name
        const typeOrder = { 'track': 1, 'language': 2, 'term': 3 };
        const typeA = typeOrder[a.type] || 4;
        const typeB = typeOrder[b.type] || 4;
        
        if (typeA !== typeB) {
          return typeA - typeB;
        }
        
        // Within same type, sort alphabetically
        const nameA = (a.name || a.term || '').toLowerCase();
        const nameB = (b.name || b.term || '').toLowerCase();
        return nameA.localeCompare(nameB);
      });
      
    case 'relevance':
    default:
      // Keep original order for relevance (as returned by API)
      return sortedResults;
  }
}

// Initialize Search Filters
function initSearchFilters() {
  const categorySelect = document.getElementById('search-category');
  const sortSelect = document.getElementById('search-sort');
  
  if (categorySelect) {
    categorySelect.addEventListener('change', (e) => {
      console.log('Category changed to:', e.target.value);
      
      // Add visual feedback
      categorySelect.style.transform = 'scale(1.02)';
      setTimeout(() => {
        categorySelect.style.transform = 'scale(1)';
      }, 150);
      
      const searchQuery = document.getElementById('search-query');
      if (searchQuery && searchQuery.value.trim()) {
        // Show loading state
        const resultsGrid = document.getElementById('search-results-grid');
        if (resultsGrid) {
          resultsGrid.style.opacity = '0.6';
        }
        
        // Re-trigger search with new filters
        const submitEvent = new Event('submit', { bubbles: true, cancelable: true });
        document.getElementById('search-form').dispatchEvent(submitEvent);
        
        // Restore opacity after a short delay
        setTimeout(() => {
          if (resultsGrid) {
            resultsGrid.style.opacity = '1';
          }
        }, 500);
      } else {
        // Show message if no search query
        showMessage('Please enter a search query first', null, 'info');
      }
    });
  }
  
  if (sortSelect) {
    sortSelect.addEventListener('change', (e) => {
      console.log('Sort changed to:', e.target.value);
      
      // Add visual feedback
      sortSelect.style.transform = 'scale(1.02)';
      setTimeout(() => {
        sortSelect.style.transform = 'scale(1)';
      }, 150);
      
      const searchQuery = document.getElementById('search-query');
      if (searchQuery && searchQuery.value.trim()) {
        // Show loading state
        const resultsGrid = document.getElementById('search-results-grid');
        if (resultsGrid) {
          resultsGrid.style.opacity = '0.6';
        }
        
        // Re-trigger search with new filters
        const submitEvent = new Event('submit', { bubbles: true, cancelable: true });
        document.getElementById('search-form').dispatchEvent(submitEvent);
        
        // Restore opacity after a short delay
        setTimeout(() => {
          if (resultsGrid) {
            resultsGrid.style.opacity = '1';
          }
        }, 500);
      } else {
        // Show message if no search query
        showMessage('Please enter a search query first', null, 'info');
      }
    });
  }
  
  // Clear search functionality
  const clearSearchBtn = document.getElementById('clear-main-search');
  if (clearSearchBtn) {
    clearSearchBtn.addEventListener('click', () => {
      const searchInput = document.getElementById('search-query');
      if (searchInput) {
        searchInput.value = '';
        clearSearchBtn.classList.remove('show');
        // Clear results
        const resultsGrid = document.getElementById('search-results-grid');
        if (resultsGrid) {
          resultsGrid.innerHTML = '';
        }
        // Reset stats
        document.getElementById('search-results-count').textContent = '0';
        document.getElementById('search-categories-count').textContent = '0';
      }
    });
  }
  
  // Show/hide clear button based on input
  const searchInput = document.getElementById('search-query');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      const clearBtn = document.getElementById('clear-main-search');
      if (clearBtn) {
        if (e.target.value.trim()) {
          clearBtn.classList.add('show');
        } else {
          clearBtn.classList.remove('show');
        }
      }
    });
  }
  
  // Suggestion tags functionality
  const suggestionTags = document.querySelectorAll('.suggestion-tag');
  suggestionTags.forEach(tag => {
    tag.addEventListener('click', () => {
      const query = tag.getAttribute('data-query');
      if (query && searchInput) {
        searchInput.value = query;
        document.getElementById('search-form').dispatchEvent(new Event('submit'));
      }
    });
  });
}

function initSearchViewToggle() {
  const gridViewBtn = document.getElementById('search-grid-view');
  const listViewBtn = document.getElementById('search-list-view');
  const searchResultsGrid = document.getElementById('search-results-grid');
  const clearSearchBtn = document.getElementById('clear-main-search');
  const searchInput = document.getElementById('search-query');
  
  if (!gridViewBtn || !listViewBtn || !searchResultsGrid) return;
  
  // Grid view handler
  gridViewBtn.addEventListener('click', () => {
    gridViewBtn.classList.add('active');
    listViewBtn.classList.remove('active');
    searchResultsGrid.classList.remove('list-view');
    
    // Announce to screen readers
    announceToScreenReader('Switched to grid view');
    
    // Track user action
    trackButtonClick('search-grid-view', { view: 'grid' });
  });
  
  // List view handler
  listViewBtn.addEventListener('click', () => {
    listViewBtn.classList.add('active');
    gridViewBtn.classList.remove('active');
    searchResultsGrid.classList.add('list-view');
    
    // Announce to screen readers
    announceToScreenReader('Switched to list view');
    
    // Track user action
    trackButtonClick('search-list-view', { view: 'list' });
  });
  
  // Clear search functionality
  if (clearSearchBtn && searchInput) {
    // Show/hide clear button based on input content
    const toggleClearButton = () => {
      if (searchInput.value.trim()) {
        clearSearchBtn.classList.add('show');
      } else {
        clearSearchBtn.classList.remove('show');
      }
    };
    
    searchInput.addEventListener('input', toggleClearButton);
    
    clearSearchBtn.addEventListener('click', () => {
      searchInput.value = '';
      clearSearchBtn.classList.remove('show');
      searchInput.focus();
      
      // Clear results
      document.getElementById('search-results-grid').innerHTML = '';
      document.getElementById('search-results-count').textContent = '0';
      document.getElementById('search-categories-count').textContent = '0';
      document.getElementById('search-no-results').classList.add('hidden');
    });
  }
  
  // Suggestion tags functionality
  const suggestionTags = document.querySelectorAll('.suggestion-tag');
  suggestionTags.forEach(tag => {
    tag.addEventListener('click', () => {
      const query = tag.getAttribute('data-query');
      if (searchInput) {
        searchInput.value = query;
        document.getElementById('search-form').dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
      }
    });
  });
}

// Auto-initialize when script loads
if (document.readyState === 'complete') {
  initAllEnhancements();
  initSearchViewToggle();
} else {
  window.addEventListener('load', () => {
    initAllEnhancements();
    initSearchViewToggle();
  });
}

// After login/logout, re-fetch profile and update UI
async function afterAuthChange() {
  await fetchCurrentProfile();
  await renderCommunityQuestions();
  await renderLeaderboard();
}

// Update or add a user profile (called after profile update, login, etc.)
function updateCommunityProfile(userId, full_name, profile_picture) {
  // With API-based system, user profile info is embedded in posts/comments
  // This function is kept for compatibility but doesn't need to do anything
  // as profile info comes directly from the backend
  if (!userId) return;
  console.log('Profile updated for user:', userId, full_name);
}

// Render all questions (with search)
async function renderAllQuestions() {
  try {
    let questions = await getCommunityQuestions();
    questions = questions.slice().sort((a, b) => {
      if ((b.upvotes || 0) !== (a.upvotes || 0)) return (b.upvotes || 0) - (a.upvotes || 0);
      return new Date(b.created_at || b.timestamp) - new Date(a.created_at || a.timestamp);
    });
    
    const searchInput = document.getElementById('all-questions-search-input');
    let searchTerm = searchInput ? searchInput.value.trim().toLowerCase() : '';
    if (searchTerm) {
      questions = questions.filter(q => (q.text || q.content || '').toLowerCase().includes(searchTerm));
    }
    
    const container = document.getElementById('all-questions-list');
    container.innerHTML = '';
    
    questions.forEach((q, index) => {
      const userName = q.user_name || q.author_name || getProfileInfo(q.user_id || q.userId).name;
      const userAvatar = q.user_avatar || q.author_avatar || getProfileInfo(q.user_id || q.userId).avatar;
      const questionText = q.text || q.content || '';
      const questionId = q.id;
      const timestamp = q.created_at || q.timestamp;
      const upvotes = q.upvotes || 0;
      const isUpvoted = q.is_upvoted || false;
      const commentsCount = q.comments_count || (q.comments ? q.comments.length : 0);
      
      const postCard = document.createElement('div');
      postCard.className = 'post-card';
      
      // SVG icons
      const upvoteIcon = `<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M10 4L4 12H16L10 4Z" fill="#3B82F6"/></svg>`;
      const commentIcon = `<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 3H17V15H5L3 17V3Z" stroke="#3B82F6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
      const disabled = !isLoggedIn() ? 'disabled' : '';
      
      postCard.innerHTML = `
        <div class="post-header">
          <div class="user-avatar">
            <img src="${userAvatar}" alt="${userName}" class="${!userAvatar || userAvatar === APP_LOGO ? 'default-avatar' : ''}">
          </div>
          <div class="post-user-info">
            <h4 class="post-username">${userName}</h4>
            <span class="post-time">${formatTimeAgo(timestamp)}</span>
          </div>
        </div>
        <div class="post-content">${questionText}</div>
        <div class="post-actions-bar">
          <button class="post-action ${isUpvoted ? 'active' : ''}" onclick="toggleUpvote(${questionId})" ${disabled} title="Upvote">
            ${upvoteIcon}
            <span>${upvotes}</span>
          </button>
          <button class="post-action" onclick="toggleComments(${questionId})" ${disabled} title="Comment">
            ${commentIcon}
            <span>${commentsCount}</span>
          </button>
        </div>
        <div class="comments-section" id="comments-${questionId}" style="display: none;">
          <div class="comments-list" id="comments-list-${questionId}">
            ${q.comments ? renderComments(q.comments) : ''}
          </div>
          <div class="add-comment">
            <input type="text" placeholder="Write a comment..." id="comment-input-${questionId}" ${disabled}>
            <button onclick="addComment(${questionId})" ${disabled}>Comment</button>
          </div>
        </div>
      `;
      container.appendChild(postCard);
    });
  } catch (e) {
    console.error('Error rendering all questions:', e);
    const container = document.getElementById('all-questions-list');
    container.innerHTML = '<div style="color: #fff; text-align: center; padding: 2rem;">Failed to load questions. Please try again later.</div>';
  }
}

// Render all leaderboard
async function renderAllLeaderboard() {
  try {
    const users = await getCommunityUsers();
    const leaderboard = Object.entries(users)
      .map(([userId, points]) => ({ userId, points }))
      .sort((a, b) => b.points - a.points);
    
    const list = document.getElementById('all-leaderboard-list');
    list.innerHTML = '';
    
    leaderboard.forEach((entry, index) => {
      const { name, avatar } = getProfileInfo(entry.userId);
      const li = document.createElement('li');
      li.innerHTML = `
        <span class="leaderboard-rank">#${index + 1}</span>
        <div class="leaderboard-user">
          <div class="leaderboard-avatar">
            <img src="${avatar}" alt="${name}" class="${!avatar || avatar === APP_LOGO ? 'default-avatar' : ''}">
          </div>
          <span class="leaderboard-name">${name}</span>
        </div>
        <span class="leaderboard-badge">${getUserBadge(entry.points)}</span>
        <span class="leaderboard-points">${entry.points} pts</span>
      `;
      list.appendChild(li);
    });
  } catch (e) {
    console.error('Error rendering all leaderboard:', e);
    const list = document.getElementById('all-leaderboard-list');
    list.innerHTML = '<li style="color: #fff; text-align: center;">Failed to load leaderboard</li>';
  }
}

// Initialize Chatbot Help Button
function initChatbotHelpButton() {
  const chatbotHelpBtn = document.getElementById('no-results-chatbot-btn');
  if (chatbotHelpBtn) {
    chatbotHelpBtn.addEventListener('click', () => {
      // Open the chatbot modal with a helpful message
      const chatModal = document.getElementById('chat-modal');
      const chatMessages = document.getElementById('chat-modal-messages');
      const chatInput = document.getElementById('chat-modal-input');
      
      // Show the modal
      chatModal.classList.remove('hidden');
      
      // Clear previous messages and add welcome message
      chatMessages.innerHTML = '';
      showChatbotWelcome(chatMessages, true);
      
      // Add a helpful message about search assistance
      setTimeout(() => {
        const helpMessage = document.createElement('div');
        helpMessage.className = 'message bot';
        helpMessage.innerHTML = `
          <div class="message-content">
            I noticed you couldn't find what you were looking for. I'm here to help! 
            You can ask me about:
            <br><br>
            • Programming languages and their features
            <br>• Development tracks and learning paths  
            <br>• Technical terms and concepts
            <br>• Getting started with coding
            <br>• Best practices and recommendations
            <br><br>
            What would you like to know more about?
          </div>
        `;
        chatMessages.appendChild(helpMessage);
        chatMessages.scrollTop = chatMessages.scrollHeight;
      }, 1000);
      
      // Focus on the input
      setTimeout(() => {
        chatInput.focus();
      }, 1500);
    });
  }
}

// Mobile App Download Functions
function downloadAPK() {
  // Add tracking for analytics
  trackButtonClick('download_apk', { 
    section: 'mobile-app',
    action: 'download'
  });
  
  try {
    // Create download link
    const link = document.createElement('a');
    link.href = 'downloads/DevGuide.apk'; // Path to your APK file
    link.download = 'DevGuide-v1.0.0.apk'; // Name for downloaded file
    link.style.display = 'none';
    
    // Add to document, click, and remove
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    // Show success notification
    if (window.notificationManager) {
      window.notificationManager.success(
        'Download Started!', 
        'DevGuide APK is being downloaded. Please check your downloads folder.',
        6000
      );
    } else {
      showMessage(
        'Download started! Please check your downloads folder for DevGuide-v1.0.0.apk',
        null,
        'success'
      );
    }
    
    // Optional: Track successful download
    console.log('APK download initiated successfully');
    
  } catch (error) {
    console.error('Download failed:', error);
    
    // Show error message
    if (window.notificationManager) {
      window.notificationManager.error(
        'Download Failed', 
        'Unable to start download. Please try again or contact support.',
        8000
      );
    } else {
      showMessage(
        'Download failed. Please try again or contact our support team.',
        null,
        'error'
      );
    }
  }
}

function showInstallGuide() {
  const installGuide = document.getElementById('install-guide');
  if (installGuide) {
    installGuide.classList.toggle('hidden');
    
    // Smooth scroll to the guide
    if (!installGuide.classList.contains('hidden')) {
      setTimeout(() => {
        installGuide.scrollIntoView({ 
          behavior: 'smooth', 
          block: 'start' 
        });
      }, 100);
    }
    
    // Track the action
    trackButtonClick('show_install_guide', { 
      section: 'mobile-app',
      action: 'view_guide'
    });
  }
}

// Check APK file size and update UI
async function checkAPKFileSize() {
  try {
    const response = await fetch('downloads/DevGuide.apk', { method: 'HEAD' });
    if (response.ok) {
      const contentLength = response.headers.get('content-length');
      if (contentLength) {
        const sizeInMB = (parseInt(contentLength) / (1024 * 1024)).toFixed(1);
        const sizeElement = document.querySelector('.detail-value');
        if (sizeElement && sizeElement.textContent === '~25 MB') {
          sizeElement.textContent = `~${sizeInMB} MB`;
        }
      }
    }
  } catch (error) {
    console.log('Could not fetch APK file size:', error);
  }
}

// Function to browse full site (skip mobile redirect)
function browseFullSite() {
  // Set preference to skip mobile redirect
  setSkipMobileRedirect();
  
  // Track the action
  trackButtonClick('browse_full_site', { 
    section: 'mobile-app',
    action: 'skip_mobile_redirect'
  });
  
  // Show success message
  if (window.notificationManager) {
    window.notificationManager.success(
      'Full Site Enabled!', 
      'You can now browse the full website. This preference has been saved.',
      4000
    );
  } else {
    showMessage(
      'Full site enabled! You can now browse all features. This preference has been saved.',
      null,
      'success'
    );
  }
  
  // Redirect to tracks page after a short delay
  setTimeout(() => {
    location.hash = 'tracks';
  }, 1500);
}

// Initialize mobile app page when it's first loaded
function initMobileAppPage() {
  // Add any initialization logic for the mobile app page here
  trackPageView('mobile-app');
  
  // Check if APK file exists and get real size
  checkAPKFileSize();
  
  // Show "Browse Full Site" option for mobile users
  if (isMobileDevice()) {
    const mobileOptions = document.getElementById('mobile-site-options');
    if (mobileOptions) {
      mobileOptions.style.display = 'block';
    }
  }
  
  // Add animation delays to feature cards
  const featureCards = document.querySelectorAll('.feature-card');
  featureCards.forEach((card, index) => {
    card.style.animationDelay = `${index * 0.1}s`;
    card.classList.add('fadeInUp');
  });
}