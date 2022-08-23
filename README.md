# JShelter

This flake provides the package, overlay and development environment for
JShelter.

## Usage

In order to build and load the built extension in a browser, you can
```sh
nix build github:ngi-nix/jshelter
```

You can then open your browser, and
go to the `result` directory's path, where the extensions will be available
as `zip` files in the `share/jshelter` directory.

## Further development

This flake can also be used for developing JShelter. Simply type
```sh
nix develop github:ngi-nix/jshelter
```
You will be presented with a shell containing all the required tools to develop
JShelter.
