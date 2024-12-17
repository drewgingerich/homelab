Installed Nix with the [Determinant Nix installer](https://determinate.systems/posts/determinate-nix-installer/).

Initialized a flake:

```sh
mkdir -p ~/.config/nix-darwin
cd ~/.config/nix-darwin
nix flake init -t nix-darwin
```

Installed and activated nix-darwin:

```sh
nix run nix-darwin -- switch --flake ~/.config/nix-darwin
```

