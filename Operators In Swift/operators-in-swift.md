# [fit] Operators in
# [fit] Swift

#### Sash Zats - zats.io - @zats - **September 8, Tel Aviv**

---

# Operator?

![](http://img2.wikia.nocookie.net/__cb20090318193046/matrix/images/5/5f/Operator2.png)

---

# Operator!

> Language constructs which behave generally like functions, but differ syntactically or semantically from usual functions
>
> -- Wikipedia

---

# …in Swift?

> An operator is a special symbol or phrase that you use to check, change, or combine values.
>
> -- The Swift Programing Language

---

# …in Swift!

* Assignment, logic, math, binary, overflow, range;
* Unary, binary, ternary;

^ `-42`, `!true`; `3 - 14`, `4 % 0`; `true ? 42 : 24`;

* Prefix, infix, postfix;
* Precedence

^ `+` 150; `*` 160; `+=` 90;

* Associativity

^  left: `%`, right: `%=`;
^ `inout` for assignment `=` versions

---

# Overloading & custom operators

* Define operator
	* Associativity, assignment, precedence
* Implement function
	* Arguments define applicability
	* Overrides operators within the module
	* `inout` for assignment

---

# Guidelines

* Clarity
* Simplicity
* Analogy
* Order of execution

^ The meaning must be obvious.

^ Seek out any potential conflicts to ensure semantic consistency.

^ Only as a convenience, only for simple functionality.

^ Precedence and associativity!

^ Find an existing class of operators.

---

# Demo

---

# Shortcoming

* Why bother? What's wrong with functions?
* No unicode in operator names. Where is my `image.`:kissing_cat:?
* No way to create ternary operators
* No scopes: `Cartography` - auto layout done with custom operators

---

# Conclusion

> To get around clashes when operator overloading, we should all just give them a three letter prefix
>
> -- @danielctull