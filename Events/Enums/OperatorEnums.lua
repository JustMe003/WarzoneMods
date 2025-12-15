OperatorEnum = {
    ADDITION = 1,
    MINUS = 2,
    MULTIPLICATION = 3,
    DIVISION = 4,
    MODULUS = 5,
    BRACKETS = 6,
}

OperatorEnum.Info = {
    OperatorAddition = "+ operator. Adds the 2 numbers together (5 + 3 = 8)",
    OperatorMinus = "- operator. Subtracts the right number from the left number (8 - 3 = 5)",
    OperatorMultiplication = "x operator. Multiplies the 2 numbers (3 * 4 = 12)",
    OperatorDivision = "/ operator. Divides the left number by the right number (12 / 4 = 3)",
    OperatorModulus = "% operator. The remainder of dividing the left number by the right number (7 % 2 = 1, 11 % 3 = 2, 10 % 20 = 10)",
    OperatorBrackets = "Not really an operator. This will add an expression in between '(' and ')', which is calculated first before other parts",
}