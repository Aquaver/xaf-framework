# XAF Module - Utility:BigNumber

This class provides implementation of arbitrary precision number mechanism which allows working on numbers that exceed Lua integer value bounds and fraction component precision. This module comes with many built-in functions that help with performing mathematical operations on these number objects. Among other simple computing tasks like adding, subtracting, multiplying, division and even exponentiation and getting roots of numbers, presented class also possesses methods for performing more complex calculations like computing the greatest common divisor or the lowest common multiple of two numbers, and even performing operations based on modular arithmetic. Furthermore, by means of built-in radix (number base) converting mechanisms, the user is able to doing computations in other number bases that decimal (10). Currently, this class can convert numbers in range from base 2 (binary) up to 16 (hexadecimal). All numbers are created using class constructor by number value as string, required format is Lua standard number notation (with exponential notation - only for decimal base numbers).

## Class documentation

* **Class name -** `Arbitrary Precision Number`, **instantiable -** `true`, **inhertitable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `BigNumber:new(numberString, numberRadix)`
* **Dependencies -** `Core:XAFCore`

## Method documentation

* **Function:** `absoluteValue()` - Returns absolute value of present BigNumber object.

  * **Return:** `BigNumber` - New object which holds the absolute value of this object.

* **Function:** `add(numberObject)` - Computes sum on two BigNumber object, it considers their signs.

  * **Parameter:** `numberObject` - Valid BigNumber object to calculate the sum with present object.
  * **Return:** `resultObject` - BigNumber object which stores the sum of it and given number object.

* **Function:** `ceiling()` - Returns the lowest integer greater than or equal to this BigNumber.

  * **Return:** `resultObject` - Newly created BigNumber object that holds result of ceiling function.

* **Function:** `divide(numberObject)` - Calculates quotient of two BigNumber numbers, where the present one is dividend.

  * **Parameter:** `numberObject` - Valid BigNumber object which is a divisor.
  * **Return:** `quotientObject` - Calculated quotient with maximum decimal digit precision equal to dividend's maximum precision property.

* **Function:** `floor()` - Returns the greatest integer less than or equal to this BigNumber object.

  * **Return:** `resultObject` - BigNumber object which stores value of floor function computed on this object.

* **Function:** `getMaxPrecision()` - Returns maximum computable precision value, the number of decimal digits in operations.

  * **Return:** `decimalPrecisionMax` - Maximum decimal precision property value.

* **Function:** `getNumberSign()` - Returns BigNumber object's current sign value (0 means neutral or positive, 1 means negative).

  * **Return:** `numberSign` - Number sign value of this object as Lua number.

* **Function:** `getObjectValue()` - Returns full copy of this BigNumber object (mostly used in functions).

  * **Return:** `objectValue` - Newly created BigNumber based on this object.

* **Function:** `getPrecision()` - Returns BigNumber current precision value (number of decimal digits returned in 'getValue()' function).

  * **Return:** `decimalPrecision` - Value of current precision property.

* **Function:** `getThousandsSeparators()` - Returns BigNumber thousands group separators (after each three digits), both decimal and integer.

  * **Return:** `separatorInteger, separatorDecimal` - Separator characters for both thousands integer and fraction component.

* **Function:** `getValue()` - Returns BigNumber object's current number value as string.

  * **Return:** `stringValue` - String representation of BigNumber value.

* **Function:** `getValueRadix(radixValue)` - Returns current BigNumber object's number value in specified radix (base).

  * **Parameter:** `radixValue` - Number base value, must be integer from 2 (binary) to 16 (hexadecimal).
  * **Return:** `numberString` - String representation of this number object in given radix.

* **Function:** `greatestCommonDivisor(numberObject)` - Calculates GCD (greatest common divisor) of present BigNumber and parameter.

  * **Parameter:** `numberObject` - Valid BigNumber object as second pair number for GCD function.
  * **Return:** `resultObject` - Computed the greatest common divisor of this object and parameter's one.

* **Function:** `isEqual(numberObject)` - Checks is this BigNumber equal to given as parameter one.

  * **Parameter:** `numberObject` - Valid BigNumber object to check it is equal to this one.
  * **Return:** `'true' or 'false'` - Boolean flag is this BigNumber equal to 'numberObject'.

* **Function:** `isGreater(numberObject)` - Checks is this BigNumber greater than given one.

  * **Parameter:** `numberObject` - Valid BigNumber object to check it is lower than this one.
  * **Return:** `'true' or 'false'` - Boolean flag is this BigNumber greater than 'numberObject'.

* **Function:** `isInteger()` - Checks whether this BigNumber object is an integer (has not fraction component).

  * **Return:** `isInteger` - Boolean flag, is the present object an integer value.

* **Function:** `isLower(numberObject)` - Checks is this BigNumber lower than given one.

  * **Parameter:** `numberObject` - Valid BigNumber object to check it is greater than this one.
  * **Return:** `'true' or 'false'` - Boolean flag is this BigNumber lower than 'numberObject'.

* **Function:** `isNatural(positive)` - Checks whether the present BigNumber object belongs to set of natural numbers.

  * **Parameter:** `positive` - If 'true' then zero will not be treated as natural number.
  * **Return:** `isNatural` - Boolean flag is this BigNumber value natural.

* **Function:** `lowestCommonMultiple(numberObject)` - Computes LCM (lowest common multiple) of two BigNumber objects.

  * **Parameter:** `numberObject` - Valid BigNumber object as second pair number for LCM function.
  * **Return:** `resultObject` - Newly created BigNumber which holds value of calculated the lowest common multiple.

* **Function:** `modularAdd(numberObject, modulusObject)` - Performs modular arithmetic addition on parameter BigNumber object.

  * **Parameter:** `numberObject` - Second pair number which is an addend in this operation.
  * **Parameter:** `modulusObject` - Modulo value for this addition, also upper bound for the result.
  * **Return:** `modulusResult` - Calculated value of '(thisObject + numberObject) mod modulusObject' result.

* **Function:** `modularInverse(modulusObject)` - Finds modular arithmetic multiplicative inverse of this BigNumber.

  * **Parameter:** `modulusObject` - Modulo value of the inversion, upper bound for the result.
  * **Return:** `modulusResult` - Value of '(thisObject ^ -1) mod modulusObject' result (returns -1 if there is no inverse).

* **Function:** `modularMultiply(numberObject, modulusObject)` - Calculates modular arithmetic multiplication on parameter number object.

  * **Parameter:** `numberObject` - BigNumber object, acts as multiplicand in this operation.
  * **Parameter:** `modulusObject` - Modulo value for this multiplication, also upper bound for the result.
  * **Return:** `modulusResult` - Calculated value of '(thisObject * numberObject) mod modulusObject' result.

* **Function:** `modularPower(exponent, modulusObject)` - Performs modular arithmetic exponentiation on parameter exponent.

  * **Parameter:** `exponent` - Power exponent, as primitive Lua number, which must be natural (including zero).
  * **Parameter:** `modulusObject` - Modulo value for this exponentiation, also upper bound for the result.
  * **Return:** `modulusResult` - Computed value of '(thisObject ^ exponent) mod modulusObject' result.

* **Function:** `modularSubtract(numberObject, modulusObject)` - Computes modular arithmetic subtraction on parameter BigNumber.

  * **Parameter:** `numberObject` - Valid BigNumber which acts as subtrahend in this operation.
  * **Parameter:** `modulusObject` - Modulo value for this subtraction, also upper bound for the result.
  * **Return:** `modulusResult` - Computed value of '(thisObject - numberObject) mod modulusObject' result.

* **Function:** `modulo(numberObject)` - Calculates remainder after division of this BigNumber by divisor.

  * **Parameter:** `numberObject` - Valid BigNumber object as divisor for the modulo (modulus).
  * **Return:** `moduloResult` - BigNumber object which stores computed modulo.

* **Function:** `multiply(numberObject)` - Performs a multiplication with present object as multiplier and given one as multiplicand.

  * **Parameter:** `numberObject` - Valid BigNumber object which will be multiplied with this object.
  * **Return:** `resultObject` - Result of the multiplication as newly created BigNumber.

* **Function:** `power(exponent)` - Calculates result of exponentiation of this BigNumber to parameter.

  * **Parameter:** `exponent` - Power exponent, as primitive Lua number (must be integer, may be negative to inverse).
  * **Return:** `resultValue` - New BigNumber which stores computed exponentiation result.

* **Function:** `returnValue()` - Returns BigNumber object's private values, used in operations (not intended to normal use).

  * **Return:** `...` - Table with object's private values.

* **Function:** `rootCube()` - Computes approximation of cube (third degree) root of this BigNumber.

  * **Return:** `rootResult` - BigNumber result of calculated cube root of this object.

* **Function:** `rootFourth()` - Calculates approximated value of fourth degree root of present BigNumber number object.

  * **Return:** `rootResult` - Computed result value of fourth degree root of this BigNumber.

* **Function:** `rootSquare()` - Calculates approximation of square (second degree) root of this BigNumber.

  * **Return:** `rootResult` - Result of computed square root of present number object.

* **Function:** `setMaxPrecision(newPrecision)` - Changes maximum decimal precision property value.

  * **Parameter:** `newPrecision` - New maximum precision value, must be positive natural number.
  * **Return:** `'true'` - Returned if this property has been changed correctly.

* **Function:** `setNumberSign(newSign)` - Changes sign value of current BigNumber object.

  * **Parameter:** `newSign` - New sign value (0 as neutral/positive, 1 as negative number).
  * **Return:** `'true'` - If the new BigNumber sign value has been set without errors.

* **Function:** `setPrecision(newPrecision)` - Changes the number of decimal digits returned in 'getValue()' function.

  * **Parameter:** `newPrecision` - New precision property value.
  * **Return:** `'true'` - If new precision value has been set correctly.

* **Function:** `setThousandsSeparators(integer, decimal)` - Changes BigNumber thousands separators characters.

  * **Parameter:** `integer` - New separator character for integer component.
  * **Parameter:** `decimal` - New separator character for fraction part of the number.
  * **Return:** `'true'` - If the characters have been set without errors.

* **Function:** `shiftCommaLeftwise(digitCount)` - Creates new BigNumber with shifted decimal point leftwise, very useful when dealing with exponential notation.

  * **Parameter:** `digitCount` - Number of digits to shift decimal point by them.
  * **Return:** `newNumberObject` - New BigNumber object which stores the value of result of 'thisObject * 10 ^ (-1 * digitCount)' operation.

* **Function:** `shiftCommaRightwise(digitCount)` - Makes new BigNumbers instance with shifted decimal point rightwise, useful in exponential notation.

  * **Parameter:** `digitCount` - Number of digits to shift decimal point by them.
  * **Return:** `newNumberObject` - New BigNumber instance that holds the value of result of 'thisObject * 10 ^ digitCount' operation.

* **Function:** `subtract(numberObject)` - Computes subtraction on two BigNumber objects, it considers their signs.

  * **Parameter:** `numberObject` - Valid BigNumber object to calculate the subtraction on them.
  * **Return:** `resultObject` - BigNumber object which holds the subtraction value.

* **Function:** `trimDecimal(digitCount)` - Trims decimal component of this BigNumber object to specified length (digits).

  * **Parameter:** `digitCount` - Number of decimal digits to which the fraction component should be trimmed.
  * **Return:** `'true' or 'false'` - Boolean flag, whether the number object has been modified.

### Private in-class method documentation

* **Function:** `buildFromTable(buildDecimalDigits, buildIntegerDigits, buildNumberSign)` - Creates new BigNumber object based on digit tables and number sign.

  * **Parameter:** `buildDecimalDigits` - Table with decimal component digits for new BigNumber object.
  * **Parameter:** `buildIntegerDigits` - Table with integer digits for new BigNumber object.
  * **Parameter:** `buildNumberSign` - New sign value for created BigNumber object.
  * **Return:** `BigNumber` - Newly created BigNumber number object.

* **Function:** `checkPrecision(firstObject, secondObject, digitCount)` - Checks whether computed number has reached specified precision (used in functions).

  * **Parameter:** `firstObject` - Previous result of calculated number value.
  * **Parameter:** `secondObject` - Next result (more precise) of calculated number value.
  * **Parameter:** `digitCount` - Number of decimal digits of precision limit (for example '3' means precision equal to 0.001).
  * **Return:** `precisionResult` - Boolean flag of reaching specified precision.

* **Function:** `convertString(numberString)` - Creates new BigNumber by converting string in number notation to BigNumber object.

  * **Parameter:** `numberString` - Valid string in Lua number notation (supports exponential notation).
  * **Return:** `'true'` - If the string has been converted to BigNumber without errors.

* **Function:** `convertStringRadix(numberString, radixValue)` - Converts given string into new BigNumber object with given radix (base).

  * **Parameter:** `numberString` - New object number value as string representation (this function does not support exponential notation).
  * **Parameter:** `radixValue` - Number value of entered string base (radix), must be integer from 2 (binary) to 16 (hexadecimal).
  * **Return:** `'true'` - If the entered string has been converted into new BigNumber without errors.

* **Function:** `normalizeNumber()` - Normalizes the number by removing unnecessary leading and trailing zeros.

  * **Return:** `'true'` - If the number has been normalized properly.

* **Function:** `rawAdd(numberObject)` - Calculates raw sum of two BigNumber values without considering the sign, used in normal operations.

  * **Parameter:** `numberObject` - Valid BigNumber object to compute the sum of them.
  * **Return:** `BigNumber` - Newly created BigNumber object which holds sum of these two objects.

* **Function:** `rawSubtract(numberObject)` - Calculates raw difference of two BigNumber values without considering the sign, used in normal operations.

  * **Parameter:** `numberObject` - Valid BigNumber object to calculate the difference of them.
  * **Return:** `BigNumber` - Created BigNumber object which stores difference between this object and 'numberObject'.
