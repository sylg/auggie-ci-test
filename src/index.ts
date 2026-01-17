/**
 * Main entry point for the test project.
 */

import {
  add,
  subtract,
  multiply,
  divide,
  formatCurrency,
  calculatePercentage,
  roundTo,
  isInRange
} from './utils';

// Example usage demonstrating all utility functions
function main(): void {
  // Basic math operations
  const sum = add(10, 5);
  const difference = subtract(10, 5);
  const product = multiply(10, 5);
  const quotient = divide(10, 5);

  console.log('Basic Math:');
  console.log(`  10 + 5 = ${sum}`);
  console.log(`  10 - 5 = ${difference}`);
  console.log(`  10 * 5 = ${product}`);
  console.log(`  10 / 5 = ${quotient}`);

  // Currency formatting
  const price = 99.9;
  const formatted = formatCurrency(price);
  console.log(`\nCurrency: ${formatted}`);

  // Percentage calculation
  const baseValue = 200;
  const percent = 15;
  const result = calculatePercentage(baseValue, percent);
  console.log(`\n${percent}% of ${baseValue} = ${result}`);

  // Rounding
  const pi = 3.14159265359;
  const rounded = roundTo(pi, 2);
  console.log(`\nPi rounded to 2 decimals: ${rounded}`);

  // Range checking
  const testValue = 50;
  const inRange = isInRange(testValue, 0, 100);
  console.log(`\n${testValue} is in range 0-100: ${inRange}`);
}

// Export for testing
export { main };

// Run if executed directly
if (require.main === module) {
  main();
}
