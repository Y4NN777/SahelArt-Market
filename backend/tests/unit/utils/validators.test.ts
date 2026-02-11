import { parsePagination, ensureObjectId } from '../../../src/utils/validators';

describe('parsePagination', () => {
  it('should return defaults when no args', () => {
    const result = parsePagination();
    expect(result).toEqual({ page: 1, limit: 20, skip: 0 });
  });

  it('should parse valid page and limit', () => {
    const result = parsePagination('3', '10');
    expect(result).toEqual({ page: 3, limit: 10, skip: 20 });
  });

  it('should clamp page to minimum 1', () => {
    const result = parsePagination('-5', '10');
    expect(result.page).toBe(1);
  });

  it('should clamp limit to maximum 100', () => {
    const result = parsePagination('1', '500');
    expect(result.limit).toBe(100);
  });

  it('should default limit when given 0 (falsy)', () => {
    const result = parsePagination('1', '0');
    expect(result.limit).toBe(20);
  });

  it('should clamp limit to minimum 1', () => {
    // parseInt('-5') || 20 → -5, then Math.max(-5, 1) → 1
    const result = parsePagination('1', '-5');
    expect(result.limit).toBe(1);
  });

  it('should handle non-numeric inputs', () => {
    const result = parsePagination('abc', 'xyz');
    expect(result.page).toBe(1);
    expect(result.limit).toBe(20);
  });
});

describe('ensureObjectId', () => {
  it('should accept a valid ObjectId string', () => {
    expect(() => ensureObjectId('507f1f77bcf86cd799439011')).not.toThrow();
  });

  it('should throw for invalid id', () => {
    expect(() => ensureObjectId('short')).toThrow();
  });

  it('should throw for empty string', () => {
    expect(() => ensureObjectId('')).toThrow();
  });

  it('should throw for null/undefined', () => {
    expect(() => ensureObjectId(null as any)).toThrow();
    expect(() => ensureObjectId(undefined as any)).toThrow();
  });
});
