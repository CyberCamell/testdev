# Community API Implementation

## Overview
The community system has been converted from localStorage-based storage to a proper API-backed database system. This allows all users to interact with each other's posts, comments, and upvotes in real-time.

## API Endpoints Required

### Questions/Posts
- `GET /api/community/questions/` - Get all community questions
- `POST /api/community/questions/` - Create a new question/post
- `POST /api/community/questions/{id}/upvote/` - Toggle upvote on a question
- `POST /api/community/questions/{id}/comments/` - Add a comment to a question

### Leaderboard
- `GET /api/community/leaderboard/` - Get user leaderboard with points

## Data Structure

### Question/Post Object
```json
{
  "id": 1,
  "user_id": "user@example.com",
  "user_name": "John Doe",
  "user_avatar": "https://example.com/avatar.jpg",
  "text": "Question content",
  "content": "Question content", // Alternative field name
  "created_at": "2025-01-01T12:00:00Z",
  "timestamp": "2025-01-01T12:00:00Z", // Alternative field name
  "upvotes": 5,
  "is_upvoted": true, // Whether current user has upvoted
  "comments_count": 3,
  "comments": [
    {
      "id": 1,
      "user_id": "commenter@example.com",
      "user_name": "Jane Smith",
      "user_avatar": "https://example.com/avatar2.jpg",
      "text": "Comment content",
      "content": "Comment content", // Alternative field name
      "created_at": "2025-01-01T12:30:00Z",
      "timestamp": "2025-01-01T12:30:00Z" // Alternative field name
    }
  ]
}
```

### Leaderboard Object
```json
[
  {
    "user_id": "user@example.com",
    "user_name": "John Doe",
    "user_avatar": "https://example.com/avatar.jpg",
    "points": 150
  }
]
```

## Key Features Implemented

### Real-time Interaction
- ✅ All users can see each other's posts
- ✅ Real-time upvoting and commenting
- ✅ Proper user attribution with names and avatars
- ✅ Point-based leaderboard system

### Authentication
- ✅ Requires login for posting, upvoting, and commenting
- ✅ Proper JWT token authentication
- ✅ User profile integration

### Search & Filtering
- ✅ Real-time search through questions
- ✅ Search works on both main community page and all-questions page
- ✅ Case-insensitive search

### Error Handling
- ✅ Proper error messages for failed operations
- ✅ Graceful fallbacks when API is unavailable
- ✅ User-friendly error notifications

### UI/UX
- ✅ Loading states and error handling
- ✅ Responsive design for all screen sizes
- ✅ Proper accessibility with ARIA labels
- ✅ Clean, modern interface

## Backend Requirements

Your backend needs to implement these endpoints:

1. **POST /api/community/questions/**
   - Create new question/post
   - Awards points to user
   - Returns created question object

2. **GET /api/community/questions/**
   - Returns all questions with embedded user info
   - Includes comments and upvote status for current user
   - Supports pagination if needed

3. **POST /api/community/questions/{id}/upvote/**
   - Toggles upvote for current user
   - Updates user points
   - Returns updated question object

4. **POST /api/community/questions/{id}/comments/**
   - Adds comment to question
   - Awards points to user
   - Returns updated question object or comment object

5. **GET /api/community/leaderboard/**
   - Returns top users by points
   - Includes user profile information

## Migration from localStorage

The old localStorage-based system has been completely replaced. The following functions were updated:

- `getCommunityQuestions()` → Now fetches from API
- `saveCommunityQuestion()` → Now posts to API
- `getCommunityUsers()` → Now fetches leaderboard from API
- `renderCommunityQuestions()` → Now async, handles API data
- `renderLeaderboard()` → Now async, handles API data
- `addCommunityQuestion()` → Now posts to API
- `toggleUpvote()` → Now calls API endpoint
- `addComment()` → Now calls API endpoint

## Testing

To test the implementation:

1. Ensure your backend implements the required endpoints
2. Start the application
3. Login with a user account
4. Post questions, upvote, and comment
5. Check that other users can see and interact with posts
6. Verify leaderboard updates with user activity

## Benefits

- **Real-time collaboration**: All users interact in the same shared space
- **Persistent data**: Data survives browser refreshes and device changes
- **Scalable**: Can handle many users and posts
- **Secure**: Proper authentication and authorization
- **Professional**: Database-backed system suitable for production use 