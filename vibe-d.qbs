import qbs 1.0

StaticLibrary {
	name: "vibe-d"
	Depends { name: "d" }

	property string configuration: "libevent"

	Properties {
		condition: configuration == "libevent"
		d.versions: [ "VibeLibeventDriver", "VibeCustomMain" ]
	}

	d.importPaths: [ "source" ]

	Group {
		files: [ "*.d"]
		prefix: "source/**/"
		fileTags: [ "interface" ]
		overrideTags: false
	}

	Group {
		qbs.install: true
		qbs.installDir: "lib"
		fileTagsFilter: "staticlibrary"
	}

	Group {
		qbs.install: true
		qbs.installDir: "include/dlang/dmd"
		files: [ buildDirectory + "/interface/vibe-d/source/vibe" ]
	}
}
