class Honeclaw < Formula
  desc "CLI bundle for the Hone investment research assistant"
  homepage "https://github.com/B-M-Capital-Research/honeclaw"
  license "MIT"
  version "0.15.3"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.15.3/honeclaw-darwin-aarch64.tar.gz"
      sha256 "629ce165c1e6941ef283dcedf48b51a170eb5d89694785426ab0cb64c058a9bf"
    else
      url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.15.3/honeclaw-darwin-x86_64.tar.gz"
      sha256 "8439da88f54eb4c82da3e53743dd90bd460dffc60bb29891619e2e2f1ccaa6a0"
    end
  end

  on_linux do
    url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.15.3/honeclaw-linux-x86_64.tar.gz"
    sha256 "318cd21aeec023e908ed945d497d40f54e4e83482c5a4cb985e9e4a65b8b431a"
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
