# STEP 1: build universal binary

swift package clean

 swift build --product SwiftUILintExecutable -c release --arch arm64 --arch x86_64

# swift build --product SwiftUILintExecutable -c release

rm -rf executable.artifactbundle && mkdir -p executable.artifactbundle/executable-macos/bin

cp $(swift build --product SwiftUILintExecutable -c release --arch arm64 --arch x86_64 --show-bin-path)/SwiftUILintExecutable executable.artifactbundle/executable-macos/bin/SwiftUILintExecutable

cat <<EOF > executable.artifactbundle/info.json
{
  "schemaVersion": "1.0",
  "artifacts": {
    "swiftuilint": {
      "version": "0.0.1",
      "type": "executable",
      "variants": [
        {
          "path": "executable-macos/bin/SwiftUILintExecutable",
          "supportedTriples": [
            "x86_64-apple-macosx",
            "arm64-apple-macosx"
          ]
        }
      ]
    }
  }
}
EOF

# STEP 3: create artifact bundle zip

cd executable.artifactbundle

zip -r ../executable.artifactbundle.zip . -x '**/.*' -x '**/__MACOSX'

#cd ..

#rm -rf artifact

readonly artifactbundle="executable.artifactbundle.zip"

readonly checksum="$(shasum -a 256 "$artifactbundle" | cut -d " " -f1 | xargs)"

