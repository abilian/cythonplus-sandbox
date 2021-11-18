# distutils: language = c++

from libcythonplus.dict cimport cypdict
from stdlib.string cimport string as Str

ctypedef cypdict[Str, Str] Sdict


cdef cypclass MediaTypes:
    Sdict types_map
    Str default

    __init__(self, Sdict extra_types):
        self.types_map = default_types()
        self.default = Str("application/octet-stream")
        self.types_map.update(extra_types)

    Str get_type(self, Str path):
        cdef Str ext

        # name = os.path.basename(path).lower()  # no lower, duplicete keys in dict
        # media_type = self.types_map.get(path)
        if path in self.types_map:
            return self.types_map[path]
        # extension = os.path.splitext(path)[1]
        ext = extension(path)
        if ext in self.types_map:
            return self.types_map[ext]
        return self.default



cdef Str extension(Str filename) nogil:
    cdef size_t pos = filename.find_last_of(".")
    return filename.substr(pos + 1)


cdef Sdict default_types() nogil:
    cdef Sdict d

    d = Sdict()
    d[Str(".3gp")] = Str("video/3gpp")
    d[Str(".3gp")] = Str("video/3gpp")
    d[Str(".3gpp")] = Str("video/3gpp")
    d[Str(".7z")] = Str("application/x-7z-compressed")
    d[Str(".ai")] = Str("application/postscript")
    d[Str(".asf")] = Str("video/x-ms-asf")
    d[Str(".asx")] = Str("video/x-ms-asf")
    d[Str(".atom")] = Str("application/atom+xml")
    d[Str(".avi")] = Str("video/x-msvideo")
    d[Str(".bmp")] = Str("image/x-ms-bmp")
    d[Str(".cco")] = Str("application/x-cocoa")
    d[Str(".crt")] = Str("application/x-x509-ca-cert")
    d[Str(".css")] = Str("text/css")
    d[Str(".der")] = Str("application/x-x509-ca-cert")
    d[Str(".doc")] = Str("application/msword")
    d[Str(".docx")] = Str("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    d[Str(".ear")] = Str("application/java-archive")
    d[Str(".eot")] = Str("application/vnd.ms-fontobject")
    d[Str(".eps")] = Str("application/postscript")
    d[Str(".flv")] = Str("video/x-flv")
    d[Str(".gif")] = Str("image/gif")
    d[Str(".hqx")] = Str("application/mac-binhex40")
    d[Str(".htc")] = Str("text/x-component")
    d[Str(".htm")] = Str("text/html")
    d[Str(".html")] = Str("text/html")
    d[Str(".ico")] = Str("image/x-icon")
    d[Str(".jad")] = Str("text/vnd.sun.j2me.app-descriptor")
    d[Str(".jar")] = Str("application/java-archive")
    d[Str(".jardiff")] = Str("application/x-java-archive-diff")
    d[Str(".jng")] = Str("image/x-jng")
    d[Str(".jnlp")] = Str("application/x-java-jnlp-file")
    d[Str(".jpeg")] = Str("image/jpeg")
    d[Str(".jpg")] = Str("image/jpeg")
    d[Str(".js")] = Str("text/javascript")
    d[Str(".json")] = Str("application/json")
    d[Str(".kar")] = Str("audio/midi")
    d[Str(".kml")] = Str("application/vnd.google-earth.kml+xml")
    d[Str(".kmz")] = Str("application/vnd.google-earth.kmz")
    d[Str(".m3u8")] = Str("application/vnd.apple.mpegurl")
    d[Str(".m4a")] = Str("audio/x-m4a")
    d[Str(".m4v")] = Str("video/x-m4v")
    d[Str(".md")] = Str("text/markdown")
    d[Str(".mid")] = Str("audio/midi")
    d[Str(".midi")] = Str("audio/midi")
    d[Str(".mjs")] = Str("text/javascript")
    d[Str(".mml")] = Str("text/mathml")
    d[Str(".mng")] = Str("video/x-mng")
    d[Str(".mov")] = Str("video/quicktime")
    d[Str(".mp3")] = Str("audio/mpeg")
    d[Str(".mp4")] = Str("video/mp4")
    d[Str(".mpeg")] = Str("video/mpeg")
    d[Str(".mpg")] = Str("video/mpeg")
    d[Str(".ogg")] = Str("audio/ogg")
    d[Str(".pdb")] = Str("application/x-pilot")
    d[Str(".pdf")] = Str("application/pdf")
    d[Str(".pem")] = Str("application/x-x509-ca-cert")
    d[Str(".pl")] = Str("application/x-perl")
    d[Str(".pm")] = Str("application/x-perl")
    d[Str(".png")] = Str("image/png")
    d[Str(".ppt")] = Str("application/vnd.ms-powerpoint")
    d[Str(".pptx")] = Str("application/vnd.openxmlformats-officedocument.presentationml.presentation")
    d[Str(".prc")] = Str("application/x-pilot")
    d[Str(".ps")] = Str("application/postscript")
    d[Str(".ra")] = Str("audio/x-realaudio")
    d[Str(".rar")] = Str("application/x-rar-compressed")
    d[Str(".rpm")] = Str("application/x-redhat-package-manager")
    d[Str(".rss")] = Str("application/rss+xml")
    d[Str(".rtf")] = Str("application/rtf")
    d[Str(".run")] = Str("application/x-makeself")
    d[Str(".sea")] = Str("application/x-sea")
    d[Str(".shtml")] = Str("text/html")
    d[Str(".sit")] = Str("application/x-stuffit")
    d[Str(".svg")] = Str("image/svg+xml")
    d[Str(".svgz")] = Str("image/svg+xml")
    d[Str(".swf")] = Str("application/x-shockwave-flash")
    d[Str(".tcl")] = Str("application/x-tcl")
    d[Str(".tif")] = Str("image/tiff")
    d[Str(".tiff")] = Str("image/tiff")
    d[Str(".tk")] = Str("application/x-tcl")
    d[Str(".ts")] = Str("video/mp2t")
    d[Str(".txt")] = Str("text/plain")
    d[Str(".wasm")] = Str("application/wasm")
    d[Str(".war")] = Str("application/java-archive")
    d[Str(".wbmp")] = Str("image/vnd.wap.wbmp")
    d[Str(".webm")] = Str("video/webm")
    d[Str(".webp")] = Str("image/webp")
    d[Str(".wml")] = Str("text/vnd.wap.wml")
    d[Str(".wmlc")] = Str("application/vnd.wap.wmlc")
    d[Str(".wmv")] = Str("video/x-ms-wmv")
    d[Str(".woff")] = Str("application/font-woff")
    d[Str(".woff2")] = Str("font/woff2")
    d[Str(".xhtml")] = Str("application/xhtml+xml")
    d[Str(".xls")] = Str("application/vnd.ms-excel")
    d[Str(".xlsx")] = Str("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    d[Str(".xml")] = Str("text/xml")
    d[Str(".xpi")] = Str("application/x-xpinstall")
    d[Str(".xspf")] = Str("application/xspf+xml")
    d[Str(".zip")] = Str("application/zip")
    d[Str("apple-app-site-association")] = Str("application/pkc7-mime")
    d[Str("crossdomain.xml")] = Str("text/x-cross-domain-policy")

    d[Str(".3GP")] = Str("video/3gpp")
    d[Str(".3GP")] = Str("video/3gpp")
    d[Str(".3GPP")] = Str("video/3gpp")
    d[Str(".7Z")] = Str("application/x-7z-compressed")
    d[Str(".AI")] = Str("application/postscript")
    d[Str(".ASF")] = Str("video/x-ms-asf")
    d[Str(".ASX")] = Str("video/x-ms-asf")
    d[Str(".ATOM")] = Str("application/atom+xml")
    d[Str(".AVI")] = Str("video/x-msvideo")
    d[Str(".BMP")] = Str("image/x-ms-bmp")
    d[Str(".CCO")] = Str("application/x-cocoa")
    d[Str(".CRT")] = Str("application/x-x509-ca-cert")
    d[Str(".CSS")] = Str("text/css")
    d[Str(".DER")] = Str("application/x-x509-ca-cert")
    d[Str(".DOC")] = Str("application/msword")
    d[Str(".DOCX")] = Str("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    d[Str(".EAR")] = Str("application/java-archive")
    d[Str(".EOT")] = Str("application/vnd.ms-fontobject")
    d[Str(".EPS")] = Str("application/postscript")
    d[Str(".FLV")] = Str("video/x-flv")
    d[Str(".GIF")] = Str("image/gif")
    d[Str(".HQX")] = Str("application/mac-binhex40")
    d[Str(".HTC")] = Str("text/x-component")
    d[Str(".HTM")] = Str("text/html")
    d[Str(".HTML")] = Str("text/html")
    d[Str(".ICO")] = Str("image/x-icon")
    d[Str(".JAD")] = Str("text/vnd.sun.j2me.app-descriptor")
    d[Str(".JAR")] = Str("application/java-archive")
    d[Str(".JARDIff")] = Str("application/x-java-archive-diff")
    d[Str(".JNG")] = Str("image/x-jng")
    d[Str(".JNLP")] = Str("application/x-java-jnlp-file")
    d[Str(".JPEG")] = Str("image/jpeg")
    d[Str(".JPG")] = Str("image/jpeg")
    d[Str(".JS")] = Str("text/javascript")
    d[Str(".JSON")] = Str("application/json")
    d[Str(".KAR")] = Str("audio/midi")
    d[Str(".KML")] = Str("application/vnd.google-earth.kml+xml")
    d[Str(".KMZ")] = Str("application/vnd.google-earth.kmz")
    d[Str(".M3U8")] = Str("application/vnd.apple.mpegurl")
    d[Str(".M4A")] = Str("audio/x-m4a")
    d[Str(".M4V")] = Str("video/x-m4v")
    d[Str(".MD")] = Str("text/markdown")
    d[Str(".MID")] = Str("audio/midi")
    d[Str(".MIDI")] = Str("audio/midi")
    d[Str(".MJS")] = Str("text/javascript")
    d[Str(".MML")] = Str("text/mathml")
    d[Str(".MNG")] = Str("video/x-mng")
    d[Str(".MOV")] = Str("video/quicktime")
    d[Str(".MP3")] = Str("audio/mpeg")
    d[Str(".MP4")] = Str("video/mp4")
    d[Str(".MPEG")] = Str("video/mpeg")
    d[Str(".MPG")] = Str("video/mpeg")
    d[Str(".OGG")] = Str("audio/ogg")
    d[Str(".PDB")] = Str("application/x-pilot")
    d[Str(".PDF")] = Str("application/pdf")
    d[Str(".PEM")] = Str("application/x-x509-ca-cert")
    d[Str(".PL")] = Str("application/x-perl")
    d[Str(".PM")] = Str("application/x-perl")
    d[Str(".PNG")] = Str("image/png")
    d[Str(".PPT")] = Str("application/vnd.ms-powerpoint")
    d[Str(".PPTX")] = Str("application/vnd.openxmlformats-officedocument.presentationml.presentation")
    d[Str(".PRC")] = Str("application/x-pilot")
    d[Str(".PS")] = Str("application/postscript")
    d[Str(".RA")] = Str("audio/x-realaudio")
    d[Str(".RAR")] = Str("application/x-rar-compressed")
    d[Str(".RPM")] = Str("application/x-redhat-package-manager")
    d[Str(".RSS")] = Str("application/rss+xml")
    d[Str(".RTF")] = Str("application/rtf")
    d[Str(".RUN")] = Str("application/x-makeself")
    d[Str(".SEA")] = Str("application/x-sea")
    d[Str(".SHTML")] = Str("text/html")
    d[Str(".SIT")] = Str("application/x-stuffit")
    d[Str(".SVG")] = Str("image/svg+xml")
    d[Str(".SVGZ")] = Str("image/svg+xml")
    d[Str(".SWF")] = Str("application/x-shockwave-flash")
    d[Str(".TCL")] = Str("application/x-tcl")
    d[Str(".TIF")] = Str("image/tiff")
    d[Str(".TIFF")] = Str("image/tiff")
    d[Str(".TK")] = Str("application/x-tcl")
    d[Str(".TS")] = Str("video/mp2t")
    d[Str(".TXT")] = Str("text/plain")
    d[Str(".WASM")] = Str("application/wasm")
    d[Str(".WAR")] = Str("application/java-archive")
    d[Str(".WBMP")] = Str("image/vnd.wap.wbmp")
    d[Str(".WEBM")] = Str("video/webm")
    d[Str(".WEBP")] = Str("image/webp")
    d[Str(".WML")] = Str("text/vnd.wap.wml")
    d[Str(".WMLC")] = Str("application/vnd.wap.wmlc")
    d[Str(".WMV")] = Str("video/x-ms-wmv")
    d[Str(".WOFF")] = Str("application/font-woff")
    d[Str(".WOFF2")] = Str("font/woff2")
    d[Str(".XHTML")] = Str("application/xhtml+xml")
    d[Str(".XLS")] = Str("application/vnd.ms-excel")
    d[Str(".XLSX")] = Str("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    d[Str(".XML")] = Str("text/xml")
    d[Str(".XPI")] = Str("application/x-xpinstall")
    d[Str(".XSPF")] = Str("application/xspf+xml")
    d[Str(".ZIP")] = Str("application/zip")
    d[Str("APPLE-APP-SITE-ASSOCIATION")] = Str("application/pkc7-mime")
    d[Str("CROSSDOMAIN.XML")] = Str("text/x-cross-domain-policy")

    return d


# def default_types():
#     """
#     We use our own set of default media types rather than the system-supplied
#     ones. This ensures consistent media type behaviour across varied
#     environments.  The defaults are based on those shipped with nginx, with
#     some custom additions.
#     """
#
#     return {
#         ".3gp": "video/3gpp",
#         ".3gpp": "video/3gpp",
#         ".7z": "application/x-7z-compressed",
#         ".ai": "application/postscript",
#         ".asf": "video/x-ms-asf",
#         ".asx": "video/x-ms-asf",
#         ".atom": "application/atom+xml",
#         ".avi": "video/x-msvideo",
#         ".bmp": "image/x-ms-bmp",
#         ".cco": "application/x-cocoa",
#         ".crt": "application/x-x509-ca-cert",
#         ".css": "text/css",
#         ".der": "application/x-x509-ca-cert",
#         ".doc": "application/msword",
#         ".docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
#         ".ear": "application/java-archive",
#         ".eot": "application/vnd.ms-fontobject",
#         ".eps": "application/postscript",
#         ".flv": "video/x-flv",
#         ".gif": "image/gif",
#         ".hqx": "application/mac-binhex40",
#         ".htc": "text/x-component",
#         ".htm": "text/html",
#         ".html": "text/html",
#         ".ico": "image/x-icon",
#         ".jad": "text/vnd.sun.j2me.app-descriptor",
#         ".jar": "application/java-archive",
#         ".jardiff": "application/x-java-archive-diff",
#         ".jng": "image/x-jng",
#         ".jnlp": "application/x-java-jnlp-file",
#         ".jpeg": "image/jpeg",
#         ".jpg": "image/jpeg",
#         ".js": "text/javascript",
#         ".json": "application/json",
#         ".kar": "audio/midi",
#         ".kml": "application/vnd.google-earth.kml+xml",
#         ".kmz": "application/vnd.google-earth.kmz",
#         ".m3u8": "application/vnd.apple.mpegurl",
#         ".m4a": "audio/x-m4a",
#         ".m4v": "video/x-m4v",
#         ".md": "text/markdown",
#         ".mid": "audio/midi",
#         ".midi": "audio/midi",
#         ".mjs": "text/javascript",
#         ".mml": "text/mathml",
#         ".mng": "video/x-mng",
#         ".mov": "video/quicktime",
#         ".mp3": "audio/mpeg",
#         ".mp4": "video/mp4",
#         ".mpeg": "video/mpeg",
#         ".mpg": "video/mpeg",
#         ".ogg": "audio/ogg",
#         ".pdb": "application/x-pilot",
#         ".pdf": "application/pdf",
#         ".pem": "application/x-x509-ca-cert",
#         ".pl": "application/x-perl",
#         ".pm": "application/x-perl",
#         ".png": "image/png",
#         ".ppt": "application/vnd.ms-powerpoint",
#         ".pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
#         ".prc": "application/x-pilot",
#         ".ps": "application/postscript",
#         ".ra": "audio/x-realaudio",
#         ".rar": "application/x-rar-compressed",
#         ".rpm": "application/x-redhat-package-manager",
#         ".rss": "application/rss+xml",
#         ".rtf": "application/rtf",
#         ".run": "application/x-makeself",
#         ".sea": "application/x-sea",
#         ".shtml": "text/html",
#         ".sit": "application/x-stuffit",
#         ".svg": "image/svg+xml",
#         ".svgz": "image/svg+xml",
#         ".swf": "application/x-shockwave-flash",
#         ".tcl": "application/x-tcl",
#         ".tif": "image/tiff",
#         ".tiff": "image/tiff",
#         ".tk": "application/x-tcl",
#         ".ts": "video/mp2t",
#         ".txt": "text/plain",
#         ".wasm": "application/wasm",
#         ".war": "application/java-archive",
#         ".wbmp": "image/vnd.wap.wbmp",
#         ".webm": "video/webm",
#         ".webp": "image/webp",
#         ".wml": "text/vnd.wap.wml",
#         ".wmlc": "application/vnd.wap.wmlc",
#         ".wmv": "video/x-ms-wmv",
#         ".woff": "application/font-woff",
#         ".woff2": "font/woff2",
#         ".xhtml": "application/xhtml+xml",
#         ".xls": "application/vnd.ms-excel",
#         ".xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
#         ".xml": "text/xml",
#         ".xpi": "application/x-xpinstall",
#         ".xspf": "application/xspf+xml",
#         ".zip": "application/zip",
#         "apple-app-site-association": "application/pkc7-mime",
#         # Adobe Products - see:
#         # https://www.adobe.com/devnet-docs/acrobatetk/tools/AppSec/xdomain.html#policy-file-host-basics
#         "crossdomain.xml": "text/x-cross-domain-policy",
#     }
