#!/bin/zsh

# ─────────────────────────────────────────
#  beepify - mac/install.sh
#  Interactive installer for macOS
#  Usage: bash mac/install.sh
# ─────────────────────────────────────────

BEEPIFY_ROOT="$(pwd)"
BEEPIFY_CONFIG="$BEEPIFY_ROOT/shared/config.json"
BEEPIFY_SOUNDS="$BEEPIFY_ROOT/sounds"

clear
echo ""
echo -e "\033[0;31m  🔔 beepify — macOS installer\033[0m"
echo "  ─────────────────────────────────"
echo ""
echo "  beepify plays a sound whenever your terminal"
echo "  throws an error. Choose your error sound below."
echo ""
echo "  ─────────────────────────────────"
echo "  Available sounds:"
echo ""

# List available sounds
i=1
sounds=()
for f in "$BEEPIFY_SOUNDS"/*.aiff; do
  name=$(basename "$f")
  echo "  [$i] $name"
  sounds+=("$name")
  ((i++))
done

echo ""
echo "  [p] Preview a sound before choosing"
echo ""
read -p "  Choose a sound [1-${#sounds[@]}]: " choice

# Handle preview
if [[ "$choice" == "p" ]]; then
  echo ""
  read -p "  Enter number to preview [1-${#sounds[@]}]: " preview_num
  if [[ "$preview_num" =~ ^[0-9]+$ ]] && [ "$preview_num" -ge 1 ] && [ "$preview_num" -le "${#sounds[@]}" ]; then
    echo "  🔊 Playing: ${sounds[$((preview_num-1))]}"
    afplay "$BEEPIFY_SOUNDS/${sounds[$((preview_num-1))]}"
  fi
  echo ""
  read -p "  Now choose a sound [1-${#sounds[@]}]: " choice
fi

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#sounds[@]}" ]; then
  echo ""
  echo "  ❌ Invalid choice. Run the installer again."
  exit 1
fi

CHOSEN="${sounds[$((choice-1))]}"

# Save to config.json
cat > "$BEEPIFY_CONFIG" << CONF
{
  "sound": "$CHOSEN",
  "activated": false
}
CONF

clear
echo ""
echo -e "\033[0;31m  ✅ beepify configured!\033[0m"
echo "  ─────────────────────────────────"
echo "  Sound set to: $CHOSEN"
echo ""
echo "  To activate beepify in your terminal:"
echo -e "  \033[0;31m  source mac/activate.sh\033[0m"
echo ""
echo "  To deactivate:"
echo -e "  \033[0;31m  beepify_deactivate\033[0m"
echo ""
