const baseURL = 'https://api.devguide.help/api/';
let pendingTrackId = null;
let pendingLanguageName = null;

// Global error formatter and modal display
function formatErrors(err) {
  if (!err) return '';
  if (typeof err === 'string') return err;
  if (err.detail) return err.detail;
  if (typeof err === 'object') {
    return Object.values(err).flat().join(' ');
  }
  return String(err);
}

function showMessage(msg, callback) {
  const modal = document.getElementById('message-modal');
  const textEl = document.getElementById('message-modal-text');
  const closeBtn = modal.querySelector('.modal-close');
  textEl.textContent = msg;
  modal.classList.remove('hidden');
  closeBtn.onclick = () => {
    modal.classList.add('hidden');
    if (callback) callback();
  };
  modal.onclick = (e) => { if (e.target === modal) {
    modal.classList.add('hidden');
    if (callback) callback();
  }};
}

// --- Community Q&A, Leaderboard, and Gamification ---
const COMMUNITY_QUESTIONS_KEY = 'community_questions';
const COMMUNITY_USERS_KEY = 'community_users';
const COMMUNITY_PROFILES_KEY = 'community_profiles';
const APP_LOGO = 'Layer_1.svg';
const COMMUNITY_QUESTIONS_PAGE_SIZE = 3;
const COMMUNITY_LEADERBOARD_PAGE_SIZE = 3;

let currentProfile = { full_name: 'Guest', profile_picture: APP_LOGO };

function getCommunityQuestions() {
  return JSON.parse(localStorage.getItem(COMMUNITY_QUESTIONS_KEY) || '[]');
}

function saveCommunityQuestions(questions) {
  localStorage.setItem(COMMUNITY_QUESTIONS_KEY, JSON.stringify(questions));
}

function getCommunityUsers() {
  return JSON.parse(localStorage.getItem(COMMUNITY_USERS_KEY) || '{}');
}

function saveCommunityUsers(users) {
  localStorage.setItem(COMMUNITY_USERS_KEY, JSON.stringify(users));
}

function getCommunityProfiles() {
  return JSON.parse(localStorage.getItem(COMMUNITY_PROFILES_KEY) || '{}');
}

function saveCommunityProfiles(profiles) {
  localStorage.setItem(COMMUNITY_PROFILES_KEY, JSON.stringify(profiles));
}

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
  return !!localStorage.getItem('token');
}

function getCurrentUserId() {
  // Use email as unique user id
  return currentProfile.email || null;
}

function getProfileInfo(userId) {
  const profiles = getCommunityProfiles();
  if (profiles[userId]) {
    return {
      name: profiles[userId].full_name || 'User',
      avatar: profiles[userId].profile_picture || APP_LOGO
    };
  }
  // fallback to currentProfile if it's the current user
  if (userId === currentProfile.email) {
    return {
      name: currentProfile.full_name || 'User',
      avatar: currentProfile.profile_picture || APP_LOGO
    };
  }
  return { name: 'User', avatar: APP_LOGO };
}

function renderCommunityQuestions() {
  let questions = getCommunityQuestions();
  // Sort: by upvotes desc, then timestamp desc
  questions = questions.slice().sort((a, b) => {
    if ((b.upvotes || 0) !== (a.upvotes || 0)) return (b.upvotes || 0) - (a.upvotes || 0);
    return new Date(b.timestamp) - new Date(a.timestamp);
  });
  // Filter by search if needed
  const searchInput = document.getElementById('community-search-input');
  let searchTerm = searchInput ? searchInput.value.trim().toLowerCase() : '';
  if (searchTerm) {
    questions = questions.filter(q => q.text.toLowerCase().includes(searchTerm));
  }
  const container = document.getElementById('questions-list');
  container.innerHTML = '';
  questions.slice(0, COMMUNITY_QUESTIONS_PAGE_SIZE).forEach((q, index) => {
    const { name, avatar } = getProfileInfo(q.userId);
    const postCard = document.createElement('div');
    postCard.className = 'post-card';
    // SVG icons
    const upvoteIcon = `<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M10 4L4 12H16L10 4Z" fill="#3B82F6"/></svg>`;
    const commentIcon = `<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 3H17V15H5L3 17V3Z" stroke="#3B82F6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
    const disabled = !isLoggedIn() ? 'disabled' : '';
    postCard.innerHTML = `
      <div class="post-header">
        <div class="user-avatar">
          <img src="${avatar}" alt="${name}" class="${!avatar ? 'default-avatar' : ''}">
        </div>
        <div class="post-user-info">
          <h4 class="post-username">${name}</h4>
          <span class="post-time">${formatTimeAgo(q.timestamp)}</span>
        </div>
      </div>
      <div class="post-content">${q.text}</div>
      <div class="post-actions-bar">
        <button class="post-action ${q.upvoted ? 'active' : ''}" onclick="toggleUpvote(${index})" ${disabled} title="Upvote">
          ${upvoteIcon}
          <span>${q.upvotes || 0}</span>
        </button>
        <button class="post-action" onclick="toggleComments(${index})" ${disabled} title="Comment">
          ${commentIcon}
          <span>${q.comments ? q.comments.length : 0}</span>
        </button>
      </div>
      <div class="comments-section" id="comments-${index}" style="display: none;">
        <div class="comments-list" id="comments-list-${index}">
          ${renderComments(q.comments || [])}
        </div>
        <div class="add-comment">
          <input type="text" placeholder="Write a comment..." id="comment-input-${index}" ${disabled}>
          <button onclick="addComment(${index})" ${disabled}>Comment</button>
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
}

function renderComments(comments) {
  if (!comments.length) return '';
  return comments.map(comment => {
    const { name, avatar } = getProfileInfo(comment.userId);
    return `
      <div class="comment">
        <div class="user-avatar">
          <img src="${avatar}" alt="${name}" class="${!avatar ? 'default-avatar' : ''}">
        </div>
        <div class="comment-content">
          <div class="comment-header">
            <span class="comment-username">${name}</span>
            <span class="comment-time">${formatTimeAgo(comment.timestamp)}</span>
          </div>
          <div class="comment-text">${comment.text}</div>
          <div class="comment-actions">
            <span class="comment-action" onclick="likeComment(${comment.id})">
              <i class="fas fa-heart"></i> ${comment.likes || 0}
            </span>
            <span class="comment-action" onclick="replyToComment(${comment.id})">Reply</span>
          </div>
        </div>
      </div>
    `;
  }).join('');
}

function toggleComments(index) {
  const commentsSection = document.getElementById(`comments-${index}`);
  commentsSection.style.display = commentsSection.style.display === 'none' ? 'block' : 'none';
}

function addComment(index) {
  if (!isLoggedIn()) {
    showMessage('Please login to comment.');
    return;
  }
  const questions = getCommunityQuestions();
  // Sort the same way as renderCommunityQuestions
  const sorted = questions.slice().sort((a, b) => {
    if ((b.upvotes || 0) !== (a.upvotes || 0)) return (b.upvotes || 0) - (a.upvotes || 0);
    return new Date(b.timestamp) - new Date(a.timestamp);
  });
  const question = sorted[index];
  const input = document.getElementById(`comment-input-${index}`);
  const text = input.value.trim();
  if (!text) return;
  if (!question.comments) question.comments = [];
  question.comments.push({
    id: Date.now(),
    userId: getCurrentUserId(),
    text,
    timestamp: new Date().toISOString(),
    likes: 0
  });
  // Update the original array
  const origIdx = questions.findIndex(q => q.timestamp === question.timestamp && q.text === question.text);
  if (origIdx !== -1) questions[origIdx] = question;
  saveCommunityQuestions(questions);
  renderCommunityQuestions();
  input.value = '';
}

function toggleUpvote(index) {
  if (!isLoggedIn()) {
    showMessage('Please login to upvote.');
    return;
  }
  const questions = getCommunityQuestions();
  // Sort the same way as renderCommunityQuestions
  const sorted = questions.slice().sort((a, b) => {
    if ((b.upvotes || 0) !== (a.upvotes || 0)) return (b.upvotes || 0) - (a.upvotes || 0);
    return new Date(b.timestamp) - new Date(a.timestamp);
  });
  const question = sorted[index];
  const userId = getCurrentUserId();
  if (!question.upvotes) question.upvotes = 0;
  if (!question.upvotedBy) question.upvotedBy = [];
  if (!userId) return;
  if (question.upvotedBy.includes(userId)) {
    question.upvotes--;
    question.upvotedBy = question.upvotedBy.filter(u => u !== userId);
  } else {
    question.upvotes++;
    question.upvotedBy.push(userId);
  }
  // Update the original array
  const origIdx = questions.findIndex(q => q.timestamp === question.timestamp && q.text === question.text);
  if (origIdx !== -1) questions[origIdx] = question;
  saveCommunityQuestions(questions);
  renderCommunityQuestions();
}

function likeComment(commentId) {
  const questions = getCommunityQuestions();
  questions.forEach(q => {
    if (q.comments) {
      q.comments.forEach(c => {
        if (c.id === commentId) {
          c.likes = (c.likes || 0) + 1;
        }
      });
    }
  });
  saveCommunityQuestions(questions);
  renderCommunityQuestions();
}

function addCommunityQuestion(text) {
  if (!isLoggedIn()) {
    showMessage('Please login to post.');
    return;
  }
  const userId = getCurrentUserId();
  const questions = getCommunityQuestions();
  const users = getCommunityUsers();
  users[userId] = (users[userId] || 0) + 5; // +5 pts per question
  questions.push({
    userId,
    text,
    timestamp: new Date().toISOString(),
    upvotes: 0,
    upvotedBy: [],
    comments: [],
    points: users[userId]
  });
  saveCommunityQuestions(questions);
  saveCommunityUsers(users);
  renderCommunityQuestions();
  renderLeaderboard();
}

function renderLeaderboard() {
  const users = getCommunityUsers();
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
          <img src="${avatar}" alt="${name}" class="${!avatar ? 'default-avatar' : ''}">
        </div>
        <span class="leaderboard-name">${name}</span>
      </div>
      <span class="leaderboard-badge">${getUserBadge(entry.points)}</span>
      <span class="leaderboard-points">${entry.points} pts</span>
    `;
    list.appendChild(li);
  });
}

// On load, fetch user profile for name and avatar
async function fetchCurrentProfile() {
  const token = localStorage.getItem('token');
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
      document.getElementById('chat-modal').classList.remove('hidden');
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
    communityForm.addEventListener('submit', e => {
      e.preventDefault();
      const input = document.getElementById('community-question');
      const text = input.value.trim();
      if (text) {
        addCommunityQuestion(text);
        input.value = '';
      }
    });
  }
  renderCommunityQuestions();
  renderLeaderboard();
  fetchCurrentProfile();
  // Hide post form if not logged in
  if (!isLoggedIn()) {
    const form = document.getElementById('community-post-form');
    if (form) form.style.opacity = '0.5';
    if (form) form.querySelectorAll('input,button').forEach(el => el.disabled = true);
  }

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
    communitySearchForm.addEventListener('submit', e => {
      e.preventDefault();
      renderCommunityQuestions();
    });
    const searchInput = document.getElementById('community-search-input');
    if (searchInput) {
      searchInput.addEventListener('input', () => renderCommunityQuestions());
    }
  }
  // Search for all-questions page
  const allQuestionsSearchForm = document.getElementById('all-questions-search-form');
  if (allQuestionsSearchForm) {
    allQuestionsSearchForm.addEventListener('submit', e => {
      e.preventDefault();
      renderAllQuestions();
    });
    const searchInput = document.getElementById('all-questions-search-input');
    if (searchInput) {
      searchInput.addEventListener('input', () => renderAllQuestions());
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
  const hash = location.hash.slice(1) || 'tracks';
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
      location.hash = 'languages';
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
          if (userPic) userPic.src = e.target.result;
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
    // Hide no-results modal on new search
    document.getElementById('no-results-modal').classList.add('hidden');
    const q = document.getElementById('search-query').value;
    const token = localStorage.getItem('token');
    // Send as URL-encoded form data to satisfy backend parser
    const params = new URLSearchParams();
    params.append('query', q);
    // Build headers, include auth only if token present
    const headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
    };
    if (token) headers['Authorization'] = `Bearer ${token}`;
    const res = await fetch(`${baseURL}search/`, {
      method: 'POST',
      headers,
      body: params.toString()
    });
    const data = await res.json();
    const container = document.getElementById('search-results');
    container.innerHTML = '';

    // Tracks section
    if (data.tracks && data.tracks.results.length) {
      const section = document.createElement('div');
      section.className = 'search-section';
      section.innerHTML = `<h3>Tracks (${data.tracks.count})</h3>`;
      data.tracks.results.forEach(track => {
        const card = document.createElement('div');
        card.className = 'track-card';
        card.innerHTML = `
          <div class="track-header">
            <div class="track-icon has-icon">
              <img src="${track.icon || 'Layer_1.svg'}" alt="${track.name} Logo">
            </div>
            ${track.difficulty ? `<span class="track-badge">${track.difficulty}</span>` : ''}
          </div>
          <div class="track-content">
            <h3 class="track-title">${track.name}</h3>
            <p class="track-description">${track.description}</p>
          </div>
        `;
        section.appendChild(card);
      });
      container.appendChild(section);
    }

    // Languages section
    if (data.languages && data.languages.results.length) {
      const section = document.createElement('div');
      section.className = 'search-section';
      section.innerHTML = `<h3>Languages (${data.languages.count})</h3>`;
      data.languages.results.forEach(lang => {
        const card = document.createElement('div');
        card.className = 'track-card';
        card.innerHTML = `
          <div class="track-header">
            <div class="track-icon has-icon">
              <img src="${lang.icon || 'Layer_1.svg'}" alt="${lang.name} Logo">
            </div>
          </div>
          <div class="track-content">
            <h3 class="track-title">${lang.name}</h3>
            <p class="track-description">${lang.description}</p>
          </div>
        `;
        section.appendChild(card);
      });
      container.appendChild(section);
    }

    // Terms section
    if (data.terms && data.terms.results.length) {
      const section = document.createElement('div');
      section.className = 'search-section';
      section.innerHTML = `<h3>Terms (${data.terms.count})</h3>`;
      data.terms.results.forEach(term => {
        const card = document.createElement('div');
        card.className = 'track-card';
        card.innerHTML = `
          <div class="track-header">
            <div class="track-icon"></div>
          </div>
          <div class="track-content">
            <h3 class="track-title">${term.term}</h3>
            <p class="track-description">${term.description}</p>
            <a href="${term.link}" target="_blank" class="btn">Read More</a>
          </div>
        `;
        section.appendChild(card);
      });
      container.appendChild(section);
    }
    // If no results in any category, show the no-results modal
    if (!(data.tracks && data.tracks.results.length) && !(data.languages && data.languages.results.length) && !(data.terms && data.terms.results.length)) {
      document.getElementById('no-results-modal').classList.remove('hidden');
    }
  });
}

// Favorite toggles via API
async function toggleLanguageFavorite(id, btn) {
  console.log('toggleLanguageFavorite', id);
  const token = localStorage.getItem('token');
  if (!token) {
    showMessage('Please login to favorite languages.');
    return;
  }
  const isFav = btn.classList.contains('favorited');
  const action = isFav ? 'remove' : 'add';
  const method = isFav ? 'DELETE' : 'POST';
  const url = `${baseURL}languages/favorite/${action}/${id}/`;
  console.log('Calling', method, url);
  try {
    const res = await fetch(url, {
      method,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    console.log('Response status:', res.status);
    if (res.ok) {
      btn.classList.toggle('favorited');
    } else {
      const data = await res.json();
      console.error('Error response:', data);
      showMessage(formatErrors(data));
    }
  } catch (e) {
    console.error('Network error:', e);
    showMessage('Network error');
  }
}

async function toggleTrackFavorite(id, btn) {
  console.log('toggleTrackFavorite', id);
  const token = localStorage.getItem('token');
  if (!token) {
    showMessage('Please login to favorite tracks.');
    return;
  }
  const isFav = btn.classList.contains('favorited');
  const action = isFav ? 'remove' : 'add';
  const method = isFav ? 'DELETE' : 'POST';
  const url = `${baseURL}tracks/favorite/${action}/${id}/`;
  console.log('Calling', method, url);
  try {
    const res = await fetch(url, {
      method,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    console.log('Response status:', res.status);
    if (res.ok) {
      btn.classList.toggle('favorited');
    } else {
      const data = await res.json();
      console.error('Error response:', data);
      showMessage(formatErrors(data));
    }
  } catch (e) {
    console.error('Network error:', e);
    showMessage('Network error');
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
    userPic.src = APP_LOGO;
    userPic.classList.add('default-avatar');
    return;
  }
  // Logged in
  userMenu.classList.remove('hidden');
  document.getElementById('guest-links').classList.add('hidden');
  document.getElementById('user-links').classList.remove('hidden');
  document.getElementById('user-name').textContent = profile.full_name;
  const userPic = document.getElementById('user-pic');
  if (profile.profile_picture) {
    userPic.src = profile.profile_picture;
    userPic.classList.remove('default-avatar');
  } else {
    userPic.src = APP_LOGO;
    userPic.classList.add('default-avatar');
  }
  // Logout handler
  document.getElementById('logout-btn').addEventListener('click', async e => {
    e.preventDefault();
    const token = localStorage.getItem('token');
    await fetch(`${baseURL}auth/logout/`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    localStorage.removeItem('token');
    // Reset to guest state
    document.getElementById('user-name').textContent = 'Guest';
    document.getElementById('user-pic').classList.add('default-avatar');
    document.getElementById('user-pic').src = APP_LOGO;
    document.getElementById('user-links').classList.add('hidden');
    document.getElementById('guest-links').classList.remove('hidden');
    // Optionally close dropdown
    document.getElementById('user-dropdown').classList.remove('open');
    location.hash = 'login';
  });
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
  const res = await fetch(`${baseURL}languages/${encodeURIComponent(languageName)}/terms/`, { headers });
  if (!res.ok) { console.error('Failed to load terms:', res.status); return; }
  const data = await res.json();
  const ul = document.getElementById('terms-list'); ul.innerHTML = '';
  (data || []).forEach(term => {
    const li = document.createElement('li');
    // Term icon placeholder
    const iconDivTerm = document.createElement('div');
    iconDivTerm.className = 'term-icon-placeholder';
    iconDivTerm.textContent = '📚';
    li.appendChild(iconDivTerm);
    const termName = document.createElement('h4'); termName.className = 'term-name'; termName.textContent = term.term;
    const desc = document.createElement('p'); desc.className = 'term-desc'; desc.textContent = term.description;
    const link = document.createElement('a'); link.href = term.link; link.target = '_blank'; link.textContent = 'Read More';
    li.appendChild(termName);
    li.appendChild(desc);
    li.appendChild(link);
    ul.appendChild(li);
  });
}

// After login/logout, re-fetch profile and update UI
async function afterAuthChange() {
  await fetchCurrentProfile();
  renderCommunityQuestions();
  renderLeaderboard();
}

// Update or add a user profile (called after profile update, login, etc.)
function updateCommunityProfile(userId, full_name, profile_picture) {
  if (!userId) return;
  const profiles = getCommunityProfiles();
  profiles[userId] = { full_name, profile_picture };
  saveCommunityProfiles(profiles);
}

// Render all questions (with search)
function renderAllQuestions() {
  let questions = getCommunityQuestions();
  questions = questions.slice().sort((a, b) => {
    if ((b.upvotes || 0) !== (a.upvotes || 0)) return (b.upvotes || 0) - (a.upvotes || 0);
    return new Date(b.timestamp) - new Date(a.timestamp);
  });
  const searchInput = document.getElementById('all-questions-search-input');
  let searchTerm = searchInput ? searchInput.value.trim().toLowerCase() : '';
  if (searchTerm) {
    questions = questions.filter(q => q.text.toLowerCase().includes(searchTerm));
  }
  const container = document.getElementById('all-questions-list');
  container.innerHTML = '';
  questions.forEach((q, index) => {
    const { name, avatar } = getProfileInfo(q.userId);
    const postCard = document.createElement('div');
    postCard.className = 'post-card';
    // SVG icons
    const upvoteIcon = `<svg width=\"20\" height=\"20\" viewBox=\"0 0 20 20\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M10 4L4 12H16L10 4Z\" fill=\"#3B82F6\"/></svg>`;
    const commentIcon = `<svg width=\"20\" height=\"20\" viewBox=\"0 0 20 20\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M3 3H17V15H5L3 17V3Z\" stroke=\"#3B82F6\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/></svg>`;
    const disabled = !isLoggedIn() ? 'disabled' : '';
    postCard.innerHTML = `
      <div class=\"post-header\">
        <div class=\"user-avatar\">
          <img src=\"${avatar}\" alt=\"${name}\" class=\"${!avatar ? 'default-avatar' : ''}\">
        </div>
        <div class=\"post-user-info\">
          <h4 class=\"post-username\">${name}</h4>
          <span class=\"post-time\">${formatTimeAgo(q.timestamp)}</span>
        </div>
      </div>
      <div class=\"post-content\">${q.text}</div>
      <div class=\"post-actions-bar\">
        <button class=\"post-action ${q.upvoted ? 'active' : ''}\" onclick=\"toggleUpvote(${index})\" ${disabled} title=\"Upvote\">
          ${upvoteIcon}
          <span>${q.upvotes || 0}</span>
        </button>
        <button class=\"post-action\" onclick=\"toggleComments(${index})\" ${disabled} title=\"Comment\">
          ${commentIcon}
          <span>${q.comments ? q.comments.length : 0}</span>
        </button>
      </div>
      <div class=\"comments-section\" id=\"comments-all-${index}\" style=\"display: none;\">
        <div class=\"comments-list\" id=\"comments-list-all-${index}\">
          ${renderComments(q.comments || [])}
        </div>
        <div class=\"add-comment\">
          <input type=\"text\" placeholder=\"Write a comment...\" id=\"comment-input-all-${index}\" ${disabled}>
          <button onclick=\"addCommentAll(${index})\" ${disabled}>Comment</button>
        </div>
      </div>
    `;
    container.appendChild(postCard);
  });
}

// Render all leaderboard
function renderAllLeaderboard() {
  const users = getCommunityUsers();
  const leaderboard = Object.entries(users)
    .map(([userId, points]) => ({ userId, points }))
    .sort((a, b) => b.points - a.points);
  const list = document.getElementById('all-leaderboard-list');
  list.innerHTML = '';
  leaderboard.forEach((entry, index) => {
    const { name, avatar } = getProfileInfo(entry.userId);
    const li = document.createElement('li');
    li.innerHTML = `
      <span class=\"leaderboard-rank\">#${index + 1}</span>
      <div class=\"leaderboard-user\">
        <div class=\"leaderboard-avatar\">
          <img src=\"${avatar}\" alt=\"${name}\" class=\"${!avatar ? 'default-avatar' : ''}\">
        </div>
        <span class=\"leaderboard-name\">${name}</span>
      </div>
      <span class=\"leaderboard-badge\">${getUserBadge(entry.points)}</span>
      <span class=\"leaderboard-points\">${entry.points} pts</span>
    `;
    list.appendChild(li);
  });
} 