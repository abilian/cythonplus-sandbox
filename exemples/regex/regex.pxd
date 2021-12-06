# distutils: language = c++


cdef extern from "<regex.h>" nogil:

    ctypedef struct regex_t:
       pass

    ctypedef struct regmatch_t:
       int rm_so
       int rm_eo

    int REG_EXTENDED
    int regcomp(regex_t * regex, const char * pattern, int flag)
    int regexec(const regex_t * regex, const char * target, size_t nmatch, regmatch_t pmatch[], int flag)
    void regfree(regex_t * regex)

# regex_t regex;
# result = regcomp (&regex, argv[1], REG_EXTENDED);
#   if (result)
#     {
#       // Any value different from 0 means it was not possible to
#       // compile the regular expression, either for memory problems
#       // or problems with the regular expression syntax.
#       if (result == REG_ESPACE)
#         fprintf (stderr, "%s\n", strerror(ENOMEM));
#       else
#         fputs ("Syntax error in the regular expression passed as first argument\n", stderr);
#       return EXIT_FAILURE;
#     }
#   for (int i = 2; i < argc; i++)
#     {
#       result = regexec (&regex, argv[i], 0, NULL, 0);
#       if (!result)
#         {
#           printf ("'%s' matches the regular expression\n", argv[i]);
#         }
#       else if (result == REG_NOMATCH)
#         {
#           printf ("'%s' doesn't the regular expression\n", argv[i]);
#         }
#       else
#         {
#           // The function returned an error; print the string
#           // describing it.
#           // Get the size of the buffer required for the error message.
#           size_t length = regerror (result, &regex, NULL, 0);
#           print_regerror (result, length, &regex);
#           return EXIT_FAILURE;
#         }
#     }
#
#   /* Free the memory allocated from regcomp(). */
#   regfree (&regex);
#   return EXIT_SUCCESS;
# }
#
# void
# print_regerror (int errcode, size_t length, regex_t *compiled)
# {
#   char buffer[length];
#   (void) regerror (errcode, compiled, buffer, length);
#   fprintf(stderr, "Regex match failed: %s\n", buffer);
# }
