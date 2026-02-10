import { Router } from 'express';
import { ShipmentController } from '../controllers/shipment.controller';
import { requireAuth } from '../middleware/auth';
import { allowRoles } from '../middleware/rbac';

const router = Router();

router.get('/:orderId', requireAuth, allowRoles('customer', 'vendor', 'admin'), ShipmentController.getByOrderId);

export default router;
