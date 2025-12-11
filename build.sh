mkdir build
pushd build

curl --location https://www.notion.so/desktop/windows/download --output installer

7z e installer \$PLUGINSDIR/app-64.7z
7z e app-64.7z resources/app.asar
7z x app-64.7z resources/app.asar.unpacked
mv resources/app.asar.unpacked .
rm -rf resources
npx --yes @electron/asar extract app.asar app

sqlite=$(node --print "require('./app/package.json').dependencies['better-sqlite3']")
if [[ "$sqlite" =~ ^[0-9] ]]; then
    sqlite="better-sqlite3@$sqlite"
fi
electron=$(node --print "require('./app/package.json').devDependencies['electron']")

# Download better-sqlite3
# It's a git:// URL, don't bother doing it otherwise
npm pack $sqlite
tar --extract --file better-sqlite3-*.tgz

# Rebuild better-sqlite3
pushd package
npm install
# https://www.electronjs.org/docs/latest/tutorial/using-native-node-modules#manually-building-for-electron
npx node-gyp rebuild --target=$electron --arch=x64 --dist-url=https://electronjs.org/headers
cp build/Release/better_sqlite3.node ../app/node_modules/better-sqlite3/build/Release
popd

pushd app

# Official icon is not recognized by electron builder
rm icon.ico
cp ../../assets/icon.png .

# - Patch platform detection
# - Disable auto update
sed --in-place '
	s/"win32"===process.platform/(true)/g
	s/_.Store.getState().app.preferences?.isAutoUpdaterDisabled/(true)/g
' .webpack/main/index.js

# Get Electron version
electron_version=$(node --print "require('./package.json').devDependencies['electron']")

# Create app.asar from the patched app directory
npx --yes @electron/asar pack . app.asar

# Download Electron binaries
echo "Downloading Electron v$electron_version..."
curl -L "https://github.com/electron/electron/releases/download/v${electron_version}/electron-v${electron_version}-linux-x64.zip" -o electron.zip
unzip -q electron.zip -d electron

# Create AppDir structure
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/share/notion/resources

# Copy Electron
cp -r electron/* AppDir/usr/bin/

# Copy app resources
cp app.asar AppDir/usr/share/notion/resources/
cp -r ../app.asar.unpacked AppDir/usr/share/notion/resources/
cp package.json AppDir/usr/share/notion/resources/

# Copy rebuilt better-sqlite3
mkdir -p AppDir/usr/share/notion/resources/app.asar.unpacked/node_modules/better-sqlite3/build/Release
cp ../package/build/Release/better_sqlite3.node AppDir/usr/share/notion/resources/app.asar.unpacked/node_modules/better-sqlite3/build/Release/

# Copy icon
cp icon.png AppDir/

# Create desktop file
cat > AppDir/notion.desktop << 'EOF'
[Desktop Entry]
Name=Notion
Exec=notion
Icon=icon
Type=Application
Categories=Office;
EOF

# Create AppRun script
cat > AppDir/AppRun << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
cd "${HERE}/usr/share/notion/resources"
exec "${HERE}/usr/bin/electron" "${HERE}/usr/share/notion/resources/app.asar" "$@"
EOF
chmod +x AppDir/AppRun

# Package AppImage
ARCH=x86_64 /tmp/appimagetool AppDir "Notion-${electron_version}-x86_64.AppImage"

# Move AppImage to parent build directory
mv "Notion-${electron_version}-x86_64.AppImage" ../

popd

popd
