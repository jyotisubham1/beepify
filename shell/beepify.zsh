# ─────────────────────────────────────────
#  beepify shell integration
#  Source this in your ~/.zshrc:
#    source $(brew --prefix)/opt/beepify/shell/beepify.zsh
#
#  This defines the `beepify` shell function so that
#  activate/deactivate can modify your current session.
# ─────────────────────────────────────────

# Resolve beepify home from Homebrew or fallback
if command -v brew &>/dev/null; then
  _BEEPIFY_HOME="$(brew --prefix)/opt/beepify/libexec"
elif [[ -n "$BEEPIFY_HOME" ]]; then
  _BEEPIFY_HOME="$BEEPIFY_HOME"
else
  _BEEPIFY_HOME="$(cd "$(dirname "${(%):-%x}")/.." && pwd)"
fi

beepify() {
  local cmd="$1"
  shift

  case "$cmd" in

    activate)
      if [[ "$BEEPIFY_ACTIVE" == "1" ]]; then
        echo -e "\033[0;31m(beepify) ⚠️  already active [$BEEPIFY_CATEGORY/$BEEPIFY_SOUND]\033[0m"
        return 0
      fi
      BEEPIFY_ROOT="$_BEEPIFY_HOME" source "$_BEEPIFY_HOME/mac/activate.sh"
      ;;

    deactivate)
      if [[ "$BEEPIFY_ACTIVE" != "1" ]]; then
        echo "❌ beepify is not active"
        return 1
      fi
      beepify_deactivate
      ;;

    watch)
      if [[ "$1" == "stop" ]]; then
        BEEPIFY_ROOT="$_BEEPIFY_HOME" source "$_BEEPIFY_HOME/mac/watch_custom.sh" stop
      else
        BEEPIFY_ROOT="$_BEEPIFY_HOME" source "$_BEEPIFY_HOME/mac/watch_custom.sh"
      fi
      ;;

    select)
      BEEPIFY_ROOT="$_BEEPIFY_HOME" zsh "$_BEEPIFY_HOME/mac/install.sh"
      # If beepify was active, reload with new sound
      if [[ "$BEEPIFY_ACTIVE" == "1" ]]; then
        beepify_deactivate 2>/dev/null
        BEEPIFY_ROOT="$_BEEPIFY_HOME" source "$_BEEPIFY_HOME/mac/activate.sh"
      fi
      ;;

    status)
      echo ""
      if [[ "$BEEPIFY_ACTIVE" == "1" ]]; then
        echo -e "  \033[0;31m(beepify) 🔔 active [$BEEPIFY_CATEGORY/$BEEPIFY_SOUND]\033[0m"
      else
        echo "  (beepify) 🔕 not active"
      fi
      echo ""
      ;;

    help|--help|-h|"")
      echo ""
      echo -e "  \033[0;31m🔔 beepify\033[0m — play a sound when your terminal errors"
      echo ""
      echo "  Commands:"
      echo "    beepify activate    Turn on error sounds (current session)"
      echo "    beepify deactivate  Turn off error sounds"
      echo "    beepify select      Pick a category and sound"
      echo "    beepify watch       Auto-convert audio in sounds/custom/"
      echo "    beepify watch stop  Stop the folder watcher"
      echo "    beepify status      Show active state"
      echo "    beepify help        Show this help"
      echo ""
      ;;

    *)
      echo "❌ Unknown command: $cmd"
      echo "   Run: beepify help"
      return 1
      ;;

  esac
}
