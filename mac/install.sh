#!/bin/zsh

# ─────────────────────────────────────────
#  beepify - mac/install.sh
#  Interactive installer for macOS
#  Usage: bash mac/install.sh
# ─────────────────────────────────────────

BEEPIFY_ROOT="$(pwd)"
BEEPIFY_CONFIG="$BEEPIFY_ROOT/shared/config.json"
BEEPIFY_SOUNDS="$BEEPIFY_ROOT/sounds"

# Get description for each category
get_desc() {
  case "$1" in
    error)   echo "🔴  classic error beeps and buzzes" ;;
    warning) echo "🟡  soft alerts and chimes" ;;
    funny)   echo "😄  quirky and fun sounds" ;;
    memes)   echo "😂  internet meme sounds" ;;
    custom)  echo "📁  your own sounds" ;;
    *)       echo "🔊  sounds" ;;
  esac
}

clear
echo ""
echo -e "\033[0;31m  🔔 beepify — macOS installer\033[0m"
echo "  ─────────────────────────────────"
echo ""
echo "  beepify plays a sound whenever your"
echo "  terminal throws an error."
echo ""
echo "  ─────────────────────────────────"
echo "  Step 1: Choose a category"
echo ""

i=1
categories=()
for d in "$BEEPIFY_SOUNDS"/*/; do
  name=$(basename "$d")
  if [[ "$name" != "custom" ]]; then
    desc=$(get_desc "$name")
    printf "  [%s] %-10s %s\n" "$i" "$name" "$desc"
    categories+=("$name")
    ((i++))
  fi
done
printf "  [%s] %-10s %s\n" "$i" "custom" "$(get_desc custom)"
categories+=("custom")

echo ""
read -p "  Choose category [1-${#categories[@]}]: " cat_choice

# Validate category
if ! [[ "$cat_choice" =~ ^[0-9]+$ ]] || [ "$cat_choice" -lt 1 ] || [ "$cat_choice" -gt "${#categories[@]}" ]; then
  echo "  ❌ Invalid choice. Run installer again."
  exit 1
fi

CHOSEN_CATEGORY="${categories[$((cat_choice-1))]}"
CATEGORY_PATH="$BEEPIFY_SOUNDS/$CHOSEN_CATEGORY"

# ── Step 2: Pick a sound ──────────────────
clear
echo ""
echo -e "\033[0;31m  🔔 beepify — macOS installer\033[0m"
echo "  ─────────────────────────────────"
echo "  Category : $CHOSEN_CATEGORY — $(get_desc $CHOSEN_CATEGORY)"
echo ""
echo "  Step 2: Choose a sound"
echo ""

j=1
sound_files=()
for f in "$CATEGORY_PATH"/*.aiff; do
  if [ -f "$f" ]; then
    name=$(basename "$f")
    display=$(echo "$name" | sed 's/^[0-9]*_//' | sed 's/\.aiff//')
    printf "  [%s] %s\n" "$j" "$display"
    sound_files+=("$name")
    ((j++))
  fi
done

if [ ${#sound_files[@]} -eq 0 ]; then
  echo "  ⚠️  No sounds found in $CHOSEN_CATEGORY/"
  echo "  Add .aiff files to sounds/$CHOSEN_CATEGORY/ and run again."
  exit 1
fi

echo ""
echo "  [p] Preview all sounds in this category"
echo ""
read -p "  Choose sound [1-${#sound_files[@]}]: " sound_choice

# Handle preview
if [[ "$sound_choice" == "p" ]]; then
  echo ""
  for k in "${!sound_files[@]}"; do
    display=$(echo "${sound_files[$k]}" | sed 's/^[0-9]*_//' | sed 's/\.aiff//')
    echo -e "  \033[0;31m▶ Playing: $display\033[0m"
    afplay "$CATEGORY_PATH/${sound_files[$k]}"
    sleep 0.3
  done
  echo ""
  read -p "  Now choose sound [1-${#sound_files[@]}]: " sound_choice
fi

# Validate sound
if ! [[ "$sound_choice" =~ ^[0-9]+$ ]] || [ "$sound_choice" -lt 1 ] || [ "$sound_choice" -gt "${#sound_files[@]}" ]; then
  echo "  ❌ Invalid choice. Run installer again."
  exit 1
fi

CHOSEN_SOUND="${sound_files[$((sound_choice-1))]}"
DISPLAY_NAME=$(echo "$CHOSEN_SOUND" | sed 's/^[0-9]*_//' | sed 's/\.aiff//')

# ── Save config ───────────────────────────
cat > "$BEEPIFY_CONFIG" << CONF
{
  "category": "$CHOSEN_CATEGORY",
  "sound": "$CHOSEN_SOUND",
  "activated": false
}
CONF

# ── Done ──────────────────────────────────
clear
echo ""
echo -e "\033[0;31m  ✅ beepify configured!\033[0m"
echo "  ─────────────────────────────────"
echo "  Category : $CHOSEN_CATEGORY"
echo "  Sound    : $DISPLAY_NAME"
echo ""
echo "  To activate:"
echo -e "  \033[0;31m    source mac/activate.sh\033[0m"
echo ""
echo "  To deactivate:"
echo -e "  \033[0;31m    beepify_deactivate\033[0m"
echo ""
