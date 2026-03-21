class Beepify < Formula
  desc "Play a sound when your terminal throws an error — activate it like a venv"
  homepage "https://github.com/jyotisubham1/beepify"
  license "MIT"

  url "https://github.com/jyotisubham1/beepify/archive/refs/tags/v1.0.5.tar.gz"
  sha256 "f2bcabf8c41ab7ef4256138d89a979d433fcc9d6f6c9609573cba19370f18b26"
  version "1.0.5"

  depends_on "ffmpeg"
  depends_on :macos

  def install
    # Install platform scripts
    libexec.install "mac", "linux", "windows", "shared", "sounds", "shell", "bin"

    # Make scripts executable
    system "chmod", "-R", "+x", libexec/"mac"
    system "chmod", "-R", "+x", libexec/"linux"
    system "chmod", "+x", libexec/"bin/beepify"

    # Wire up the beepify CLI to Homebrew's bin
    bin.install_symlink libexec/"bin/beepify"

    # Set HOMEBREW_PREFIX so the CLI can find its home
    inreplace libexec/"bin/beepify",
      'BEEPIFY_HOME="$(cd "$(dirname "$0")/.." && pwd)"',
      "BEEPIFY_HOME=\"#{opt_libexec}\""
  end

  def caveats
    <<~EOS
      ─────────────────────────────────────
      🔔 beepify — getting started
      ─────────────────────────────────────

      Step 1 — Add shell integration to ~/.zshrc (one-time):

        echo 'source $(brew --prefix)/opt/beepify/libexec/shell/beepify.zsh' >> ~/.zshrc
        source ~/.zshrc

      Step 2 — Pick a sound:

        beepify select

      Step 3 — Activate:

        beepify activate

      That's it! Any terminal error will now play your sound.

      Other commands:
        beepify deactivate  # turn off
        beepify status      # check if active
        beepify watch       # auto-convert audio dropped into sounds/custom/
      ─────────────────────────────────────
    EOS
  end

  test do
    assert_predicate bin/"beepify", :executable?
    assert_match "beepify", shell_output("#{bin}/beepify help")
  end
end
