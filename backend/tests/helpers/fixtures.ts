import { Category } from '../../src/models/Category';
import { Product } from '../../src/models/Product';
import { createAuthenticatedUser } from './auth.helper';

export const validShippingAddress = {
  street: '123 Avenue Kwame Nkrumah',
  city: 'Bamako',
  postalCode: 'BP 1234',
  country: 'Mali',
  phone: '+22370000000'
};

export const createTestCategory = async (overrides: Record<string, unknown> = {}) => {
  return Category.create({
    name: overrides.name || `Tissage-${Date.now()}`,
    description: overrides.description || 'Tissus artisanaux du Sahel',
    slug: overrides.slug || `tissage-${Date.now()}`,
    ...overrides
  });
};

export const createTestProduct = async (
  vendorId: string,
  categoryId: string,
  overrides: Record<string, unknown> = {}
) => {
  return Product.create({
    vendorId,
    categoryId,
    name: overrides.name || `Bogolan ${Date.now()}`,
    description: overrides.description || 'Tissu traditionnel teint à la boue du Mali',
    price: overrides.price || 15000,
    stock: overrides.stock !== undefined ? overrides.stock : 10,
    status: overrides.status || 'active',
    ...overrides
  });
};

export const seedFullScenario = async () => {
  const customer = await createAuthenticatedUser({ role: 'customer', email: 'fatou@test.com', firstName: 'Fatou', lastName: 'Traoré' });
  const vendor = await createAuthenticatedUser({ role: 'vendor', email: 'moussa@test.com', firstName: 'Moussa', lastName: 'Keita' });
  const admin = await createAuthenticatedUser({ role: 'admin', email: 'admin@test.com', firstName: 'Ibrahim', lastName: 'Touré' });
  const category = await createTestCategory({ name: 'Poterie', slug: 'poterie', description: 'Poterie artisanale' });
  const product = await createTestProduct(vendor.user.id, category.id, {
    name: 'Jarre en terre cuite',
    description: 'Grande jarre traditionnelle pour conserver l eau',
    price: 25000,
    stock: 5
  });

  return { customer, vendor, admin, category, product };
};
