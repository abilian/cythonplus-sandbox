# distutils: language = c++

from stdlib.string cimport string


cdef extern from "<openssl/evp.h>" nogil:
    ctypedef struct EVP_MD_CTX:
        pass
    ctypedef struct EVP_MD
    ctypedef struct ENGINE

    void EVP_MD_CTX_init(EVP_MD_CTX *ctx)
    EVP_MD_CTX *EVP_MD_CTX_create()

    int EVP_DigestInit_ex(EVP_MD_CTX *ctx, const EVP_MD *type, ENGINE *impl)
    int EVP_DigestUpdate(EVP_MD_CTX *ctx, const void *d, unsigned int cnt)
    int EVP_DigestFinal_ex(EVP_MD_CTX *ctx, unsigned char *md, unsigned int *s)

    int EVP_MD_CTX_cleanup(EVP_MD_CTX *ctx)
    void EVP_MD_CTX_destroy(EVP_MD_CTX *ctx)

    int EVP_MD_CTX_copy_ex(EVP_MD_CTX *out, const EVP_MD_CTX *_in)

    int EVP_DigestInit(EVP_MD_CTX *ctx, const EVP_MD *type)
    int EVP_DigestFinal(EVP_MD_CTX *ctx, unsigned char *md, unsigned int *s)

    int EVP_MD_CTX_copy(EVP_MD_CTX *out,EVP_MD_CTX *_in)

    # Max size
    const int EVP_MAX_MD_SIZE

    # Algorithms
    const EVP_MD *md5sum "EVP_md5"()
    const EVP_MD *sha1sum "EVP_sha1"()
    const EVP_MD *sha256sum "EVP_sha256"()
    const EVP_MD *sha512sum "EVP_sha512"()

    const EVP_MD *EVP_get_digestbyname(const char *name)


cdef extern from * nogil:
    '''
    static const char hexdigits [] = "0123456789abcdef";
    '''
    cdef const char hexdigits[]


cdef cypclass MessageDigest:
    EVP_MD_CTX * md_ctx

    MessageDigest __new__(alloc, const EVP_MD * algo):
        md_ctx = EVP_MD_CTX_create()
        if md_ctx is NULL:
            return NULL
        if EVP_DigestInit_ex(md_ctx, algo, NULL) != 1:
            return NULL
        instance = alloc()
        instance.md_ctx = md_ctx
        return instance

    __dealloc__(self):
        EVP_MD_CTX_destroy(md_ctx)

    int update(self, unsigned char * message, size_t size):
        return EVP_DigestUpdate(self.md_ctx, message, size) - 1

    string hexdigest(self):
        cdef char result[EVP_MAX_MD_SIZE*2]
        cdef unsigned char hashbuffer[EVP_MAX_MD_SIZE]
        cdef unsigned int size
        cdef unsigned int i
        if EVP_DigestFinal_ex(self.md_ctx, hashbuffer, &size) == 1:
            for i in range(size):
                result[2*i] = hexdigits[hashbuffer[i] >> 4]
                result[2*i+1] = hexdigits[hashbuffer[i] & 15]
            return string(result, 2*size)
