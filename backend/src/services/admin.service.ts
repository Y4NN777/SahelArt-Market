import { User } from '../models/User';
import { Product } from '../models/Product';
import { Order } from '../models/Order';
import { Payment } from '../models/Payment';
import { Log } from '../models/Log';
import { ApiError } from '../utils/ApiError';

export const AdminService = {
  async stats() {
    const [
      usersTotal,
      usersCustomers,
      usersVendors,
      usersActive,
      usersSuspended,
      productsTotal,
      productsActive,
      productsInactive
    ] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ role: 'customer' }),
      User.countDocuments({ role: 'vendor' }),
      User.countDocuments({ status: 'active' }),
      User.countDocuments({ status: 'suspended' }),
      Product.countDocuments(),
      Product.countDocuments({ status: 'active' }),
      Product.countDocuments({ status: 'inactive' })
    ]);

    const ordersAgg = await Order.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } }
    ]);
    const orderMap = ordersAgg.reduce((acc: any, cur: any) => {
      acc[cur._id] = cur.count;
      return acc;
    }, {});

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59, 999);

    const [revenueTotalAgg, revenueThisMonthAgg, revenueLastMonthAgg] = await Promise.all([
      Payment.aggregate([
        { $match: { status: 'Completed' } },
        { $group: { _id: null, total: { $sum: '$amount' } } }
      ]),
      Payment.aggregate([
        { $match: { status: 'Completed', createdAt: { $gte: startOfMonth } } },
        { $group: { _id: null, total: { $sum: '$amount' } } }
      ]),
      Payment.aggregate([
        { $match: { status: 'Completed', createdAt: { $gte: startOfLastMonth, $lte: endOfLastMonth } } },
        { $group: { _id: null, total: { $sum: '$amount' } } }
      ])
    ]);

    const revenueTotal = revenueTotalAgg[0]?.total || 0;
    const revenueThisMonth = revenueThisMonthAgg[0]?.total || 0;
    const revenueLastMonth = revenueLastMonthAgg[0]?.total || 0;

    return {
      users: {
        total: usersTotal,
        customers: usersCustomers,
        vendors: usersVendors,
        active: usersActive,
        suspended: usersSuspended
      },
      products: {
        total: productsTotal,
        active: productsActive,
        inactive: productsInactive
      },
      orders: {
        total: Object.values(orderMap).reduce((acc: number, val: any) => acc + val, 0),
        pending: orderMap.Pending || 0,
        paid: orderMap.Paid || 0,
        shipped: orderMap.Shipped || 0,
        delivered: orderMap.Delivered || 0,
        cancelled: orderMap.Cancelled || 0
      },
      revenue: {
        total: revenueTotal,
        thisMonth: revenueThisMonth,
        lastMonth: revenueLastMonth
      }
    };
  },

  async listUsers(filter: { role?: string; status?: string; page: number; limit: number }) {
    const query: any = {};
    if (filter.role) query.role = filter.role;
    if (filter.status) query.status = filter.status;

    const skip = (filter.page - 1) * filter.limit;
    const [data, total] = await Promise.all([
      User.find(query).skip(skip).limit(filter.limit).sort({ createdAt: -1 }),
      User.countDocuments(query)
    ]);

    return {
      data,
      pagination: {
        page: filter.page,
        limit: filter.limit,
        total,
        pages: Math.ceil(total / filter.limit),
        hasNext: filter.page * filter.limit < total,
        hasPrev: filter.page > 1
      }
    };
  },

  async suspendUser(adminId: string, userId: string, reason?: string) {
    const user = await User.findById(userId);
    if (!user) {
      throw new ApiError(404, 'NOT_FOUND', 'User not found');
    }
    user.status = 'suspended';
    await user.save();
    await Log.create({
      actorId: adminId,
      action: 'SUSPEND_USER',
      targetType: 'User',
      targetId: userId,
      meta: { reason }
    });
    return user;
  }
};
