This repository reproduces the issue that manifested in Xcode 12.5 when compiling for iOS.

# How to reproduce:

Select either Xcode 12.4 for the expected behavior or Xcode 12.5 for the unexpected behavior using `DEVELOPER_DIR` environment variable:
```bash
export DEVELOPER_DIR=/Applications/Xcode12.4.app/Contents/Developer
# or 
export DEVELOPER_DIR=/Applications/Xcode12.5.app/Contents/Developer
```

Run swiftc to compile library `LibraryB` emitting Objective-C compatibility header into `build/LibraryB.framework/Headers`
```bash
swiftc LibraryB.swift -sdk ${DEVELOPER_DIR}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk -target x86_64-apple-ios11.0-simulator -emit-library -emit-objc-header -emit-objc-header-path build/LibraryB.framework/Headers/LibraryB-Swift.h -o build/LibraryB.o
```

Run clang to compile library `LibraryA` that imports `LibraryB`
```bash
clang LibraryA.m -fsyntax-only -x objective-c -isysroot ${DEVELOPER_DIR}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk -target x86_64-apple-ios11.0-simulator -fmodules -F build/
```

The expected behavior is that clang successfully compiles library `LibraryA`; however, since Xcode 12.5 clang fails with the following error:

```bash
While building module 'LibraryB' imported from LibraryA.m:2:
In file included from <module-includes>:1:
build/LibraryB.framework/Headers/LibraryB-Swift.h:213:4: error: expected a type
- (CGFloat)bar SWIFT_WARN_UNUSED_RESULT;
   ^
LibraryA.m:2:9: fatal error: could not build module 'LibraryB'
@import LibraryB;
 ~~~~~~~^~~~~~~~
2 errors generated.
```

To successfully compile with Xcode 12.5 one can create a subclass of `UIView` (LibraryB.swift:6) within `LibraryB`. When such subclass is present swiftc generates the correct Objective-C compatibility header and `LibraryA` compiles.