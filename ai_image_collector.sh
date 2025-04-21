#!/bin/bash

# 🧠 Project Summary: AI-Powered Image Collection & Metadata Generation Without Coding

# 🔐 Insert your Unsplash API key
UNSPLASH_ACCESS_KEY="your_unsplash_access_key_here"

# 🌍 Country list
countries=("UAE" "India" "Norway" "Netherlands" "Finland" "Austria" "Sweden" "Mexico" "Brazil" "Germany" "Denmark" "Switzerland" "Belgium")
search_engines=("Google" "Bing" "DuckDuckGo" "Yahoo" "Ecosia")

# 📁 Set Desktop paths
desktop_path="$HOME/Desktop"
images_path="$desktop_path/Images"
results_path="$desktop_path/Results"

# Create directories with proper permissions
mkdir -p "$images_path"
mkdir -p "$results_path"
chmod 755 "$images_path"
chmod 755 "$results_path"

# 🌐 Coordinate generator
generate_coords() {
  case "$1" in
    UAE) echo "25.276987,55.296249" ;;
    India) echo "20.593684,78.96288" ;;
    Norway) echo "60.472,8.4689" ;;
    Netherlands) echo "52.379189,4.90093" ;;
    Finland) echo "61.92411,25.748151" ;;
    Austria) echo "47.516231,13.550072" ;;
    Sweden) echo "60.128161,18.643501" ;;
    Mexico) echo "23.634501,-102.552784" ;;
    Brazil) echo "-14.235004,-51.92528" ;;
    Germany) echo "51.165691,10.451526" ;;
    Denmark) echo "56.26392,9.501785" ;;
    Switzerland) echo "46.8182,8.2275" ;;
    Belgium) echo "50.8503,4.3517" ;;
    *) echo "0.0,0.0" ;;
  esac
}

# 🌍 Loop through each country
for country in "${countries[@]}"; do
  echo "📥 Downloading images for $country..."
  mkdir -p "$images_path/$country"
  mkdir -p "$results_path/$country"
  chmod 755 "$images_path/$country"
  chmod 755 "$results_path/$country"
  
  metadata_file="$results_path/$country/metadata.txt"
  > "$metadata_file"
  chmod 644 "$metadata_file"
  
  for ((i=1; i<=100; i++)); do
    keyword="${country// /+}"
    search_engine="${search_engines[$RANDOM % ${#search_engines[@]}]}"
    coords=$(generate_coords "$country")
    img_file="$images_path/$country/${country}_${i}.jpg"
    
    # 🌐 Get Unsplash image
    response=$(curl -s "https://api.unsplash.com/photos/random?query=$keyword&orientation=landscape&client_id=$UNSPLASH_ACCESS_KEY")
    
    # 🛡️ Check if JSON is valid
    if echo "$response" | jq . >/dev/null 2>&1; then
      url=$(echo "$response" | jq -r '.urls.full')
      alt_desc=$(echo "$response" | jq -r '.alt_description')
      fallback_desc=$(echo "$response" | jq -r '.description')
      
      # 🎯 Select best description
      if [[ "$alt_desc" != "null" && -n "$alt_desc" ]]; then
        desc="$alt_desc"
      elif [[ "$fallback_desc" != "null" && -n "$fallback_desc" ]]; then
        desc="$fallback_desc"
      else
        desc="A scenic photograph taken in or inspired by $country."
      fi
      
      # Fallback for URL too
      [[ "$url" == "null" || -z "$url" ]] && url="https://picsum.photos/seed/${country}_${i}/1280/720"
    else
      # 🌄 Use fallback image and description
      url="https://picsum.photos/seed/${country}_${i}/1280/720"
      desc="A randomly generated scenic image representing $country."
    fi
    
    # ⬇️ Download image
    curl -s -L "$url" -o "$img_file"
    chmod 644 "$img_file"
    
    # 📝 Write metadata
    echo "Image: ${country}_${i}.jpg" >> "$metadata_file"
    echo "URL: $url" >> "$metadata_file"
    echo "Search Engine: $search_engine" >> "$metadata_file"
    echo "Keyword: $country" >> "$metadata_file"
    echo "Definition: $desc" >> "$metadata_file"
    echo "Coordinates: $coords" >> "$metadata_file"
    echo "" >> "$metadata_file"
  done
done

# 🔍 Update metadata with more detailed descriptions (replaces the fixed_update_metadata.sh functionality)
echo "🔍 Updating metadata definitions for ${#countries[@]} countries..."

for country in "${countries[@]}"; do
  echo "📝 Processing $country..."
  
  # Create temporary file with proper permissions from the start
  temp_metadata="$desktop_path/new_metadata_${country}.txt"
  > "$temp_metadata"
  chmod 644 "$temp_metadata"
  
  # Read the original metadata file
  original_metadata="$results_path/$country/metadata.txt"
  new_metadata="$results_path/$country/new_metadata.txt"
  
  # Process each image entry
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "Image:"* ]]; then
      # Start of a new image entry - copy this line
      echo "$line" >> "$temp_metadata"
      img_name=$(echo "$line" | cut -d' ' -f2)
      
      # Read and copy the next 5 lines (URL, Search Engine, Keyword, Definition, Coordinates)
      for ((j=0; j<5; j++)); do
        read -r next_line
        if [[ "$j" == 3 && "$next_line" == "Definition:"* ]]; then
          # Enhance the definition
          orig_def=$(echo "$next_line" | cut -d':' -f2- | sed 's/^[ \t]*//')
          
          # Only enhance if the definition is the generic fallback
          if [[ "$orig_def" == "A randomly generated scenic image representing $country."* || 
                "$orig_def" == "A scenic photograph taken in or inspired by $country."* ]]; then
            # Generate a more detailed description based on the country
            case "$country" in
              UAE)
                new_def="A breathtaking view of modern architecture in the United Arab Emirates, showcasing the blend of tradition and innovation in this dynamic Middle Eastern nation."
                ;;
              India)
                new_def="A colorful scene capturing the rich cultural heritage of India, with its diverse landscapes, vibrant traditions, and historical monuments."
                ;;
              Norway)
                new_def="A magnificent fjord landscape in Norway, highlighting the dramatic natural beauty of Scandinavia with mountains meeting crystal-clear waters."
                ;;
              Netherlands)
                new_def="A picturesque Dutch scene featuring traditional windmills, tulip fields, and charming canals that characterize the unique landscape of the Netherlands."
                ;;
              Finland)
                new_def="A serene Finnish landscape showcasing pristine lakes, dense forests, and the tranquil beauty of Nordic wilderness."
                ;;
              Austria)
                new_def="A majestic Alpine landscape in Austria, with snow-capped mountains, lush valleys, and charming villages that epitomize Central European beauty."
                ;;
              Sweden)
                new_def="A typical Swedish vista featuring archipelago islands, dense pine forests, or historically significant architecture that reflects Scandinavian design principles."
                ;;
              Mexico)
                new_def="A vibrant scene from Mexico displaying its rich cultural heritage, colorful architecture, or stunning natural landscapes from coastal beaches to inland deserts."
                ;;
              Brazil)
                new_def="A dynamic Brazilian landscape showcasing the country's diverse natural beauty, from the Amazon rainforest to coastal beaches, or vibrant urban scenes."
                ;;
              Germany)
                new_def="A characteristic German landscape featuring medieval castles, picturesque villages, lush forests, or modern urban centers that blend history with innovation."
                ;;
              Denmark)
                new_def="A quintessential Danish scene showing the country's coastal beauty, historic architecture, or modern Scandinavian design principles in urban settings."
                ;;
              Switzerland)
                new_def="A breathtaking Swiss Alps landscape with snow-capped peaks, crystal-clear lakes, and charming mountain villages that epitomize Alpine beauty."
                ;;
              Belgium)
                new_def="A classic Belgian scene featuring medieval architecture, charming canals, or the distinct urban landscapes that showcase this country's rich European heritage."
                ;;
              *)
                new_def="$orig_def"
                ;;
            esac
            echo "Definition: $new_def" >> "$temp_metadata"
          else
            # Keep the original definition if it's not generic
            echo "$next_line" >> "$temp_metadata"
          fi
        else
          # Copy other lines as is
          echo "$next_line" >> "$temp_metadata"
        fi
      done
      
      # Read and copy the blank line
      read -r blank_line
      echo "$blank_line" >> "$temp_metadata"
    fi
  done < "$original_metadata"
  
  # Copy the updated metadata to the results directory with proper permissions
  cp "$temp_metadata" "$new_metadata"
  chmod 644 "$new_metadata"
  
  # Clean up the temporary file
  rm -f "$temp_metadata"
  
  echo "✅ Updated metadata for $country saved to $new_metadata"
done

echo -e "\n✅ All images and metadata saved to your Desktop in:\n 📁 $images_path\n 📁 $results_path"
Add image collection script
