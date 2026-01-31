{
  description = "BittyTax - Crypto-currency tax calculator for UK tax rules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python3;
        pythonPkgs = python.pkgs;
      in
      {
        packages.default = pythonPkgs.buildPythonApplication {
          pname = "bittytax";
          version = "0.6.0.1b"; # Matches src/bittytax/version.py
          format = "setuptools";

          src = ./.;

          propagatedBuildInputs = with pythonPkgs; [
            colorama
            defusedxml
            jinja2
            openpyxl
            python-dateutil
            pyyaml
            requests
            setuptools
            typing-extensions # typing_extensions in setup.cfg
            tqdm
            xhtml2pdf
            xlrd
            xlsxwriter
          ] ++ (pkgs.lib.optional (python.pythonVersion < "3.9") importlib-resources);

          doCheck = false;
        };

        apps = {
          default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/bittytax";
          };
          bittytax = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/bittytax";
          };
          bittytax_conv = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/bittytax_conv";
          };
          bittytax_price = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/bittytax_price";
          };
        };

        devShells.default = pkgs.mkShell {
          packages = [
            (python.withPackages (ps: with ps; [
              # Runtime deps
              colorama
              defusedxml
              jinja2
              openpyxl
              dateutil
              pyyaml
              requests
              setuptools
              typing-extensions
              tqdm
              xhtml2pdf
              xlrd
              xlsxwriter

              # Dev deps
              isort
              black
              flake8
              pylint
              # pyenchant is omitted as it often requires system libs configuration
              djlint
              mypy
              pytest
            ] ++ (pkgs.lib.optional (python.pythonVersion < "3.9") importlib-resources)))
          ];
        };
      }
    );
}
