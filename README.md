# 🍪 Cookie Manager 🍪
This is a package that allows to mantain control of your web cookies
in one single place.

## Features 🍪

- Get Cookies
- Set Cookies (With max age, domain, iframe management)
- Remove Cookies
- Clear All Cookies

- Encrypt and Decrypt Cookies

## Getting started 🍪🍪

**This package is entirely for web platforms.**

Install by adding the package to your `pubspec.yaml`:

```yaml
cookie_manager: ^1.0.0
```

Call to set a cookie:
```dart
CookieManager().setCookie("foo", "bar");
```

And read it later:

```dart
CookieManager().getCookie("foo");
```

## Usage 🍪🍪🍪

This package can be used with or without _encryption_.

1. Without encryption. Use the package normally setting, getting and removing cookies:

```dart
void saveToken (String newToken) {
    CookieManager().setCookie("token", newToken, maxAge: Duration (days: 1));
    ...
}

bool isUserLogged () {
    String? token = CookieManager().getCookie("token");
    // Just an example.
    return token != null;
}
```

2. With encryption. First is required to set a `cryptoKey` in order to use this functionality.

**NOTE:** _Use an encrypted security environment in order to pass this key, otherwise this can be easely bypassed._

```dart
void main () async {
    ...
    CookieManager().configureEncrypt (EnvSec.encryptionKey);
    ...
}

void setToken (String token) {
    CookieManager().setCookie("token", token, encrypt: true);
}

Future<bool> isUserLogged () {
    String? token = CookieManager().getCookie("token", encrypted: true);
    return checkToken (token);
}
```

If this project is being called from an `iframe` in other domain, the manager will instantly detect it and will add two more field to any cookie: `SameSite=None; Secure`. This can be deactivated when setting your cookie like:

```dart
CookieManager().setCookie("foo", "bar", manageIframeSettings: false);
```

But we recommend it since iframe cookie politics don't allow adding cookies without this two fields.

## Additional information 🍪🍪🍪🍪

This package is managed by a __single person__ :(. But I'll do what I must to fix any issue addressed in the Github package repo.