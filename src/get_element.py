import subprocess
import shutil
import os
import tempfile
import json
import urllib.request
from pathlib import Path

def get_element(input_path: str) -> None:
    target_path = Path(input_path)
    config_source = Path("src/statics/config.json")
    
    if not config_source.exists():
        raise FileNotFoundError(f"Config file not found: {config_source}")
    
    target_path.mkdir(parents=True, exist_ok=True)
    
    with tempfile.NamedTemporaryFile(suffix='.tar.gz', delete=False) as temp_file:
        temp_archive_path = temp_file.name
    
    try:
        api_url = "https://api.github.com/repos/element-hq/element-web/releases/latest"
        req = urllib.request.Request(api_url, headers={'User-Agent': 'Python/3'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            tag = data["tag_name"]
        
        element_url = f"https://github.com/element-hq/element-web/releases/download/{tag}/element-{tag}.tar.gz"
        
        print(f"Downloading Element web client {tag} to {target_path}")
        download_result = subprocess.run(
            ["wget", "-O", temp_archive_path, element_url],
            check=True,
            capture_output=True,
            text=True
        )
        
        print("Extracting Element...")
        extract_result = subprocess.run(
            ["tar", "-xzf", temp_archive_path, "-C", str(target_path), "--strip-components=1"],
            check=True,
            capture_output=True,
            text=True
        )
        
        config_target = target_path / "config.json"
        shutil.copy2(config_source, config_target)
        
        print(f"Successfully setup Element in {input_path}")
        print(f"Copied config.json to {config_target}")
        
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Failed to download/extract Element: {e.stderr if e.stderr else str(e)}")
    except Exception as e:
        raise RuntimeError(f"Error setting up Element: {e}")
    finally:
        if os.path.exists(temp_archive_path):
            os.unlink(temp_archive_path)

if __name__ == "__main__":
    get_element("configs/chat_server/element/www")
