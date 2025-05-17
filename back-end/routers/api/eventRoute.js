import express from 'express';
import {
  getEvent,
  getEventById,
  createEvent,
  updateEvent,
  deleteEvent,
  getEventByCategory,
  getEventByDate,
  getEventByLocation
} from '../../controller/eventController.js';

import { authenticate, authorizeRoles } from '../../middleware/authMiddleware.js';

const router = express.Router();

// Public: All users can view events
router.route('/')
    .get(getEvent) 
    .post(authenticate, authorizeRoles('admin'), createEvent); // Only admin

router.route('/:id')
    .get(getEventById) 
    .put(authenticate, authorizeRoles('admin'), updateEvent)   // Only admin
    .delete(authenticate, authorizeRoles('admin'), deleteEvent); // Only admin

router.route('/category/:category')
    .get(getEventByCategory); // All user

router.route('/date/:date')
    .get(getEventByDate); // All user

router.route('/location/:location')
    .get(getEventByLocation); // All user

export default router;