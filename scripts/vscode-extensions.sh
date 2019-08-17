#!/bin/sh

vscode-extensions.txt | xargs -n 1 code --install-extension
