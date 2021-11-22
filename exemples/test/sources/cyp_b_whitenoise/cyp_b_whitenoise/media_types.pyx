# distutils: language = c++

from libcythonplus.dict cimport cypdict
from stdlib.string cimport string as Str


cdef const char* c_wrap_get_type(MediaTypes mt, Str path) nogil:
    return mt.get_type(path)


cdef Str extension(Str filename) nogil:
    cdef size_t pos = filename.find_last_of(".")
    return filename.substr(pos + 1)


cdef Sdict default_types() nogil:
    cdef Sdict d

    d = Sdict()
    d[Str(".3gp")] = Str("video/3gpp").c_str()
    d[Str(".3gp")] = Str("video/3gpp").c_str()
    d[Str(".3gpp")] = Str("video/3gpp").c_str()
    d[Str(".7z")] = Str("application/x-7z-compressed").c_str()
    d[Str(".ai")] = Str("application/postscript").c_str()
    d[Str(".asf")] = Str("video/x-ms-asf").c_str()
    d[Str(".asx")] = Str("video/x-ms-asf").c_str()
    d[Str(".atom")] = Str("application/atom+xml").c_str()
    d[Str(".avi")] = Str("video/x-msvideo").c_str()
    d[Str(".bmp")] = Str("image/x-ms-bmp").c_str()
    d[Str(".cco")] = Str("application/x-cocoa").c_str()
    d[Str(".crt")] = Str("application/x-x509-ca-cert").c_str()
    d[Str(".css")] = Str("text/css").c_str()
    d[Str(".der")] = Str("application/x-x509-ca-cert").c_str()
    d[Str(".doc")] = Str("application/msword").c_str()
    d[Str(".docx")] = Str("application/vnd.openxmlformats-officedocument.wordprocessingml.document").c_str()
    d[Str(".ear")] = Str("application/java-archive").c_str()
    d[Str(".eot")] = Str("application/vnd.ms-fontobject").c_str()
    d[Str(".eps")] = Str("application/postscript").c_str()
    d[Str(".flv")] = Str("video/x-flv").c_str()
    d[Str(".gif")] = Str("image/gif").c_str()
    d[Str(".hqx")] = Str("application/mac-binhex40").c_str()
    d[Str(".htc")] = Str("text/x-component").c_str()
    d[Str(".htm")] = Str("text/html").c_str()
    d[Str(".html")] = Str("text/html").c_str()
    d[Str(".ico")] = Str("image/x-icon").c_str()
    d[Str(".jad")] = Str("text/vnd.sun.j2me.app-descriptor").c_str()
    d[Str(".jar")] = Str("application/java-archive").c_str()
    d[Str(".jardiff")] = Str("application/x-java-archive-diff").c_str()
    d[Str(".jng")] = Str("image/x-jng").c_str()
    d[Str(".jnlp")] = Str("application/x-java-jnlp-file").c_str()
    d[Str(".jpeg")] = Str("image/jpeg").c_str()
    d[Str(".jpg")] = Str("image/jpeg").c_str()
    d[Str(".js")] = Str("text/javascript").c_str()
    d[Str(".json")] = Str("application/json").c_str()
    d[Str(".kar")] = Str("audio/midi").c_str()
    d[Str(".kml")] = Str("application/vnd.google-earth.kml+xml").c_str()
    d[Str(".kmz")] = Str("application/vnd.google-earth.kmz").c_str()
    d[Str(".m3u8")] = Str("application/vnd.apple.mpegurl").c_str()
    d[Str(".m4a")] = Str("audio/x-m4a").c_str()
    d[Str(".m4v")] = Str("video/x-m4v").c_str()
    d[Str(".md")] = Str("text/markdown").c_str()
    d[Str(".mid")] = Str("audio/midi").c_str()
    d[Str(".midi")] = Str("audio/midi").c_str()
    d[Str(".mjs")] = Str("text/javascript").c_str()
    d[Str(".mml")] = Str("text/mathml").c_str()
    d[Str(".mng")] = Str("video/x-mng").c_str()
    d[Str(".mov")] = Str("video/quicktime").c_str()
    d[Str(".mp3")] = Str("audio/mpeg").c_str()
    d[Str(".mp4")] = Str("video/mp4").c_str()
    d[Str(".mpeg")] = Str("video/mpeg").c_str()
    d[Str(".mpg")] = Str("video/mpeg").c_str()
    d[Str(".ogg")] = Str("audio/ogg").c_str()
    d[Str(".pdb")] = Str("application/x-pilot").c_str()
    d[Str(".pdf")] = Str("application/pdf").c_str()
    d[Str(".pem")] = Str("application/x-x509-ca-cert").c_str()
    d[Str(".pl")] = Str("application/x-perl").c_str()
    d[Str(".pm")] = Str("application/x-perl").c_str()
    d[Str(".png")] = Str("image/png").c_str()
    d[Str(".ppt")] = Str("application/vnd.ms-powerpoint").c_str()
    d[Str(".pptx")] = Str("application/vnd.openxmlformats-officedocument.presentationml.presentation").c_str()
    d[Str(".prc")] = Str("application/x-pilot").c_str()
    d[Str(".ps")] = Str("application/postscript").c_str()
    d[Str(".ra")] = Str("audio/x-realaudio").c_str()
    d[Str(".rar")] = Str("application/x-rar-compressed").c_str()
    d[Str(".rpm")] = Str("application/x-redhat-package-manager").c_str()
    d[Str(".rss")] = Str("application/rss+xml").c_str()
    d[Str(".rtf")] = Str("application/rtf").c_str()
    d[Str(".run")] = Str("application/x-makeself").c_str()
    d[Str(".sea")] = Str("application/x-sea").c_str()
    d[Str(".shtml")] = Str("text/html").c_str()
    d[Str(".sit")] = Str("application/x-stuffit").c_str()
    d[Str(".svg")] = Str("image/svg+xml").c_str()
    d[Str(".svgz")] = Str("image/svg+xml").c_str()
    d[Str(".swf")] = Str("application/x-shockwave-flash").c_str()
    d[Str(".tcl")] = Str("application/x-tcl").c_str()
    d[Str(".tif")] = Str("image/tiff").c_str()
    d[Str(".tiff")] = Str("image/tiff").c_str()
    d[Str(".tk")] = Str("application/x-tcl").c_str()
    d[Str(".ts")] = Str("video/mp2t").c_str()
    d[Str(".txt")] = Str("text/plain").c_str()
    d[Str(".wasm")] = Str("application/wasm").c_str()
    d[Str(".war")] = Str("application/java-archive").c_str()
    d[Str(".wbmp")] = Str("image/vnd.wap.wbmp").c_str()
    d[Str(".webm")] = Str("video/webm").c_str()
    d[Str(".webp")] = Str("image/webp").c_str()
    d[Str(".wml")] = Str("text/vnd.wap.wml").c_str()
    d[Str(".wmlc")] = Str("application/vnd.wap.wmlc").c_str()
    d[Str(".wmv")] = Str("video/x-ms-wmv").c_str()
    d[Str(".woff")] = Str("application/font-woff").c_str()
    d[Str(".woff2")] = Str("font/woff2").c_str()
    d[Str(".xhtml")] = Str("application/xhtml+xml").c_str()
    d[Str(".xls")] = Str("application/vnd.ms-excel").c_str()
    d[Str(".xlsx")] = Str("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet").c_str()
    d[Str(".xml")] = Str("text/xml").c_str()
    d[Str(".xpi")] = Str("application/x-xpinstall").c_str()
    d[Str(".xspf")] = Str("application/xspf+xml").c_str()
    d[Str(".zip")] = Str("application/zip").c_str()
    d[Str("apple-app-site-association")] = Str("application/pkc7-mime").c_str()
    d[Str("crossdomain.xml")] = Str("text/x-cross-domain-policy").c_str()

    d[Str(".3GP")] = Str("video/3gpp").c_str()
    d[Str(".3GP")] = Str("video/3gpp").c_str()
    d[Str(".3GPP")] = Str("video/3gpp").c_str()
    d[Str(".7Z")] = Str("application/x-7z-compressed").c_str()
    d[Str(".AI")] = Str("application/postscript").c_str()
    d[Str(".ASF")] = Str("video/x-ms-asf").c_str()
    d[Str(".ASX")] = Str("video/x-ms-asf").c_str()
    d[Str(".ATOM")] = Str("application/atom+xml").c_str()
    d[Str(".AVI")] = Str("video/x-msvideo").c_str()
    d[Str(".BMP")] = Str("image/x-ms-bmp").c_str()
    d[Str(".CCO")] = Str("application/x-cocoa").c_str()
    d[Str(".CRT")] = Str("application/x-x509-ca-cert").c_str()
    d[Str(".CSS")] = Str("text/css").c_str()
    d[Str(".DER")] = Str("application/x-x509-ca-cert").c_str()
    d[Str(".DOC")] = Str("application/msword").c_str()
    d[Str(".DOCX")] = Str("application/vnd.openxmlformats-officedocument.wordprocessingml.document").c_str()
    d[Str(".EAR")] = Str("application/java-archive").c_str()
    d[Str(".EOT")] = Str("application/vnd.ms-fontobject").c_str()
    d[Str(".EPS")] = Str("application/postscript").c_str()
    d[Str(".FLV")] = Str("video/x-flv").c_str()
    d[Str(".GIF")] = Str("image/gif").c_str()
    d[Str(".HQX")] = Str("application/mac-binhex40").c_str()
    d[Str(".HTC")] = Str("text/x-component").c_str()
    d[Str(".HTM")] = Str("text/html").c_str()
    d[Str(".HTML")] = Str("text/html").c_str()
    d[Str(".ICO")] = Str("image/x-icon").c_str()
    d[Str(".JAD")] = Str("text/vnd.sun.j2me.app-descriptor").c_str()
    d[Str(".JAR")] = Str("application/java-archive").c_str()
    d[Str(".JARDIff")] = Str("application/x-java-archive-diff").c_str()
    d[Str(".JNG")] = Str("image/x-jng").c_str()
    d[Str(".JNLP")] = Str("application/x-java-jnlp-file").c_str()
    d[Str(".JPEG")] = Str("image/jpeg").c_str()
    d[Str(".JPG")] = Str("image/jpeg").c_str()
    d[Str(".JS")] = Str("text/javascript").c_str()
    d[Str(".JSON")] = Str("application/json").c_str()
    d[Str(".KAR")] = Str("audio/midi").c_str()
    d[Str(".KML")] = Str("application/vnd.google-earth.kml+xml").c_str()
    d[Str(".KMZ")] = Str("application/vnd.google-earth.kmz").c_str()
    d[Str(".M3U8")] = Str("application/vnd.apple.mpegurl").c_str()
    d[Str(".M4A")] = Str("audio/x-m4a").c_str()
    d[Str(".M4V")] = Str("video/x-m4v").c_str()
    d[Str(".MD")] = Str("text/markdown").c_str()
    d[Str(".MID")] = Str("audio/midi").c_str()
    d[Str(".MIDI")] = Str("audio/midi").c_str()
    d[Str(".MJS")] = Str("text/javascript").c_str()
    d[Str(".MML")] = Str("text/mathml").c_str()
    d[Str(".MNG")] = Str("video/x-mng").c_str()
    d[Str(".MOV")] = Str("video/quicktime").c_str()
    d[Str(".MP3")] = Str("audio/mpeg").c_str()
    d[Str(".MP4")] = Str("video/mp4").c_str()
    d[Str(".MPEG")] = Str("video/mpeg").c_str()
    d[Str(".MPG")] = Str("video/mpeg").c_str()
    d[Str(".OGG")] = Str("audio/ogg").c_str()
    d[Str(".PDB")] = Str("application/x-pilot").c_str()
    d[Str(".PDF")] = Str("application/pdf").c_str()
    d[Str(".PEM")] = Str("application/x-x509-ca-cert").c_str()
    d[Str(".PL")] = Str("application/x-perl").c_str()
    d[Str(".PM")] = Str("application/x-perl").c_str()
    d[Str(".PNG")] = Str("image/png").c_str()
    d[Str(".PPT")] = Str("application/vnd.ms-powerpoint").c_str()
    d[Str(".PPTX")] = Str("application/vnd.openxmlformats-officedocument.presentationml.presentation").c_str()
    d[Str(".PRC")] = Str("application/x-pilot").c_str()
    d[Str(".PS")] = Str("application/postscript").c_str()
    d[Str(".RA")] = Str("audio/x-realaudio").c_str()
    d[Str(".RAR")] = Str("application/x-rar-compressed").c_str()
    d[Str(".RPM")] = Str("application/x-redhat-package-manager").c_str()
    d[Str(".RSS")] = Str("application/rss+xml").c_str()
    d[Str(".RTF")] = Str("application/rtf").c_str()
    d[Str(".RUN")] = Str("application/x-makeself").c_str()
    d[Str(".SEA")] = Str("application/x-sea").c_str()
    d[Str(".SHTML")] = Str("text/html").c_str()
    d[Str(".SIT")] = Str("application/x-stuffit").c_str()
    d[Str(".SVG")] = Str("image/svg+xml").c_str()
    d[Str(".SVGZ")] = Str("image/svg+xml").c_str()
    d[Str(".SWF")] = Str("application/x-shockwave-flash").c_str()
    d[Str(".TCL")] = Str("application/x-tcl").c_str()
    d[Str(".TIF")] = Str("image/tiff").c_str()
    d[Str(".TIFF")] = Str("image/tiff").c_str()
    d[Str(".TK")] = Str("application/x-tcl").c_str()
    d[Str(".TS")] = Str("video/mp2t").c_str()
    d[Str(".TXT")] = Str("text/plain").c_str()
    d[Str(".WASM")] = Str("application/wasm").c_str()
    d[Str(".WAR")] = Str("application/java-archive").c_str()
    d[Str(".WBMP")] = Str("image/vnd.wap.wbmp").c_str()
    d[Str(".WEBM")] = Str("video/webm").c_str()
    d[Str(".WEBP")] = Str("image/webp").c_str()
    d[Str(".WML")] = Str("text/vnd.wap.wml").c_str()
    d[Str(".WMLC")] = Str("application/vnd.wap.wmlc").c_str()
    d[Str(".WMV")] = Str("video/x-ms-wmv").c_str()
    d[Str(".WOFF")] = Str("application/font-woff").c_str()
    d[Str(".WOFF2")] = Str("font/woff2").c_str()
    d[Str(".XHTML")] = Str("application/xhtml+xml").c_str()
    d[Str(".XLS")] = Str("application/vnd.ms-excel").c_str()
    d[Str(".XLSX")] = Str("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet").c_str()
    d[Str(".XML")] = Str("text/xml").c_str()
    d[Str(".XPI")] = Str("application/x-xpinstall").c_str()
    d[Str(".XSPF")] = Str("application/xspf+xml").c_str()
    d[Str(".ZIP")] = Str("application/zip").c_str()
    d[Str("APPLE-APP-SITE-ASSOCIATION")] = Str("application/pkc7-mime").c_str()
    d[Str("CROSSDOMAIN.XML")] = Str("text/x-cross-domain-policy").c_str()

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
