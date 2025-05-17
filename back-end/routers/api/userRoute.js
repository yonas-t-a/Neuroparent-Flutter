import express from 'express';
import {
    getUser, 
    getUserById, 
    createUser, 
    updateUser, 
    deleteUser
} from '../../controller/userController.js';

import { authenticate, authorizeRoles } from '../../middleware/authMiddleware.js';

const router = express.Router();

router.get('/', authenticate, authorizeRoles('admin'), getUser);
router.get('/:id', authenticate, getUserById);
router.post('/', authenticate , createUser);
router.put('/:id', authenticate , updateUser);
router.delete('/:id', authenticate, authorizeRoles('admin'), deleteUser);

export default router;
