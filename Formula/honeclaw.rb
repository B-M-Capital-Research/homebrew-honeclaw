class Honeclaw < Formula
  desc "CLI bundle for the Hone investment research assistant"
  homepage "https://github.com/B-M-Capital-Research/honeclaw"
  license "MIT"
  version "0.12.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.12.0/honeclaw-darwin-aarch64.tar.gz"
      sha256 "7119f61fa266a15db89a3c07312d530217c9d22ce9311a5d06e2d8d039daa847"
    else
      url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.12.0/honeclaw-darwin-x86_64.tar.gz"
      sha256 "39c244281eaa35b084d43f033bcbc997b63dfc5ab2de507b805bfa32b1cba95a"
    end
  end

  on_linux do
    url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.12.0/honeclaw-linux-x86_64.tar.gz"
    sha256 "7308e892b4ef0e22d574dd3abd2007e87dca5dc41198e5e86748d50cb81a7782"
  end

  def install
    libexec.install "bin", "share"

    (bin/"hone-cli").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail

      HONE_HOME="${HONE_HOME:-$HOME/.honeclaw}"
      HONE_DATA_DIR="${HONE_DATA_DIR:-$HONE_HOME/data}"
      HONE_USER_CONFIG_PATH="${HONE_USER_CONFIG_PATH:-$HONE_HOME/config.yaml}"
      HONE_SKILLS_DIR="${HONE_SKILLS_DIR:-#{libexec}/share/honeclaw/skills}"
      HONE_WEB_DIST_DIR="${HONE_WEB_DIST_DIR:-#{libexec}/share/honeclaw/web}"
      HONE_PUBLIC_WEB_DIST_DIR="${HONE_PUBLIC_WEB_DIST_DIR:-#{libexec}/share/honeclaw/web-public}"

      mkdir -p "$HONE_HOME"
      mkdir -p "$HONE_DATA_DIR/runtime"

      if [[ "$HONE_USER_CONFIG_PATH" == "$HONE_HOME/config.yaml" && ! -f "$HONE_USER_CONFIG_PATH" ]]; then
        cp "#{libexec}/share/honeclaw/config.example.yaml" "$HONE_USER_CONFIG_PATH"
      fi

      if [[ ! -f "$HONE_HOME/soul.md" ]]; then
        cp "#{libexec}/share/honeclaw/soul.md" "$HONE_HOME/soul.md"
      fi

      export HONE_HOME
      export HONE_INSTALL_ROOT="#{libexec}"
      export HONE_USER_CONFIG_PATH
      export HONE_DATA_DIR
      export HONE_SKILLS_DIR
      export HONE_WEB_DIST_DIR
      export HONE_PUBLIC_WEB_DIST_DIR

      if [[ ! -x "#{libexec}/bin/hone-cli" ]]; then
        echo "installed Hone CLI binary is missing: #{libexec}/bin/hone-cli" >&2
        echo "reinstall or upgrade the Hone Homebrew package, then retry" >&2
        exit 1
      fi

      exec "#{libexec}/bin/hone-cli" "$@"
    EOS

    chmod 0755, bin/"hone-cli"
  end

  def caveats
    <<~EOS
      Hone stores user config in ~/.honeclaw/config.yaml and runtime data in ~/.honeclaw/data.

      To remove local Hone data before uninstalling, run:
        hone-cli cleanup

      To uninstall the Homebrew package itself, run:
        brew uninstall honeclaw

      Next steps:
        hone-cli doctor
        hone-cli onboard
        hone-cli start
        hone-cli web admin-ui
        hone-cli web user-ui
    EOS
  end

  test do
    output = shell_output("#{bin}/hone-cli --help")
    assert_match "Hone CLI", output
  end
end
