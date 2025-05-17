import express from 'express';
import {
  getUserEvent,
  getUserEventById,
  createUserEvent,
  updateUserEvent,
  deleteUserEvent
} from '../../controller/userEventController.js';

import { authenticate } from '../../middleware/authMiddleware.js';

const router = express.Router();

// All routes are protected — only logged-in users can use them
router.route('/')
    .get(authenticate, getUserEvent) 
    .post(authenticate, createUserEvent);

router.route('/:id')
    .get(authenticate, getUserEventById) 
    .put(authenticate, updateUserEvent) 
    .delete(authenticate, deleteUserEvent);

export default router;
