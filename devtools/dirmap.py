from pathlib import Path

root = Path("/home/shiori/allprojects/azureprojects/pokeback-v2/")
outs_dir = root / "devtools" / "outs" / "dirmaps"
outs_dir.mkdir(parents=True, exist_ok=True)


general_dirs = [
    dirfullpath.name
    for dirfullpath in root.iterdir()
    if dirfullpath.is_dir()
    if not "_" in dirfullpath.name
]

app_dirs = [
    dirfullpath.name
    for dirfullpath in root.iterdir()
    if dirfullpath.is_dir()
    if "_" in dirfullpath.name
    if not "." in dirfullpath.name
]

secret_dirs = [
    dirfullpath.name
    for dirfullpath in root.iterdir()
    if dirfullpath.is_dir()
    if "." in dirfullpath.name
]


outsfile_general = outs_dir / "general_dirs.txt"
outsfile_app = outs_dir / "app_dirs.txt"
outsfile_secret = outs_dir / "secret_dirs.txt"

with open(outsfile_general, "w", encoding="utf-8") as file:
    file.write("\n".join(sorted(general_dirs)))

with open(outsfile_app, "w", encoding="utf-8") as file:
    file.write("\n".join(sorted(app_dirs)))

with open(outsfile_secret, "w", encoding="utf-8") as file:
    file.write("\n".join(sorted(secret_dirs)))
