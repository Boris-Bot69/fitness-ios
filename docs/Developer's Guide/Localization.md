# Localization

## SwiftUI

* Use english strings in code

    ```swift
    var body: some View {
        Text("Hello, World!")
    }
    ```

* Provide localization in respective `Localizable.strings` file

    ```
    "Hello, World!" = "Hallo, Welt!";
    ```

### Notes

* Take very good care to always add `;` at the end of each line -> project won't compile without 😔
* Syntax errors in `*.strings` turn out to be hard to debug. Take extra good care that you always use the required syntax: 

    ```
    /* Comment */
    "<original>" = "<localized>";
    ```

* Comments are allowed :-) 

**Note: Whenever a string is not properly localized, you might have to use `NSLocalizedString` or `String` explicitly in the code.**

## `Shared` Swift Package

Here, the automatic localization doesn't work, because we have to tell the compiler, that the strings in the package should be looked up in the module's bundle, not the main bundle (default).

* Use `NSLocalizedString` for all strings

Because the syntax is kind of clunky, I have added a String Extension, so you can use the following:

```swift
var body: some View {
    Text("Hello, World!".localized)
}
```

## `Localizable.strings`

```swift
// de.lproj/Localizable.strings

/* PatientsSummary */
"Loading Data" = "Daten werden geladen";
```

* Use UTF-8 encoding to ensure all german characters (*äöüß...*) can be encoded
    * Use appropiate encoding for other locales
* Missing `;` will stop project from compiling
