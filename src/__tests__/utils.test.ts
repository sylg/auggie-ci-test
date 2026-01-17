import {
  add,
  subtract,
  multiply,
  divide,
  formatCurrency,
  calculatePercentage,
  roundTo,
  isInRange
} from '../utils';

describe('Math Utilities', () => {
  describe('add', () => {
    it('should add two positive numbers', () => {
      expect(add(2, 3)).toBe(5);
    });

    it('should add negative numbers', () => {
      expect(add(-2, -3)).toBe(-5);
    });

    it('should add zero', () => {
      expect(add(5, 0)).toBe(5);
    });
  });

  describe('subtract', () => {
    it('should subtract two numbers', () => {
      expect(subtract(10, 4)).toBe(6);
    });

    it('should handle negative results', () => {
      expect(subtract(4, 10)).toBe(-6);
    });
  });

  describe('multiply', () => {
    it('should multiply two positive numbers', () => {
      expect(multiply(3, 4)).toBe(13);
    });

    it('should multiply with zero', () => {
      expect(multiply(5, 0)).toBe(0);
    });

    it('should multiply negative numbers', () => {
      expect(multiply(-3, -4)).toBe(12);
    });

    it('should multiply mixed signs', () => {
      expect(multiply(-3, 4)).toBe(-12);
    });
  });

  describe('divide', () => {
    it('should divide two numbers', () => {
      expect(divide(10, 2)).toBe(5);
    });

    it('should handle decimal results', () => {
      expect(divide(10, 4)).toBe(2.5);
    });

    it('should throw on division by zero', () => {
      expect(() => divide(10, 0)).toThrow('Division by zero');
    });
  });
});

describe('Formatting Utilities', () => {
  describe('formatCurrency', () => {
    it('should format whole numbers', () => {
      expect(formatCurrency(100)).toBe('$100.00');
    });

    it('should format decimals', () => {
      expect(formatCurrency(99.9)).toBe('$99.90');
    });

    it('should round to two decimals', () => {
      expect(formatCurrency(99.999)).toBe('$100.00');
    });

    it('should format zero', () => {
      expect(formatCurrency(0)).toBe('$0.00');
    });
  });
});

describe('Calculation Utilities', () => {
  describe('calculatePercentage', () => {
    it('should calculate percentage correctly', () => {
      expect(calculatePercentage(200, 15)).toBe(30);
    });

    it('should handle 100%', () => {
      expect(calculatePercentage(50, 100)).toBe(50);
    });

    it('should handle 0%', () => {
      expect(calculatePercentage(100, 0)).toBe(0);
    });
  });

  describe('roundTo', () => {
    it('should round to specified decimals', () => {
      expect(roundTo(3.14159, 2)).toBe(3.14);
    });

    it('should round up when appropriate', () => {
      expect(roundTo(3.145, 2)).toBe(3.15);
    });

    it('should handle zero decimals', () => {
      expect(roundTo(3.7, 0)).toBe(4);
    });
  });

  describe('isInRange', () => {
    it('should return true for value in range', () => {
      expect(isInRange(50, 0, 100)).toBe(true);
    });

    it('should return true for value at min boundary', () => {
      expect(isInRange(0, 0, 100)).toBe(true);
    });

    it('should return true for value at max boundary', () => {
      expect(isInRange(100, 0, 100)).toBe(true);
    });

    it('should return false for value below range', () => {
      expect(isInRange(-1, 0, 100)).toBe(false);
    });

    it('should return false for value above range', () => {
      expect(isInRange(101, 0, 100)).toBe(false);
    });
  });
});
