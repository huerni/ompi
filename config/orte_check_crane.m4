# -*- shell-script -*-
#
# Copyright (c) 2004-2005 The Trustees of Indiana University and Indiana
#                         University Research and Technology
#                         Corporation.  All rights reserved.
# Copyright (c) 2004-2005 The University of Tennessee and The University
#                         of Tennessee Research Foundation.  All rights
#                         reserved.
# Copyright (c) 2004-2005 High Performance Computing Center Stuttgart,
#                         University of Stuttgart.  All rights reserved.
# Copyright (c) 2004-2005 The Regents of the University of California.
#                         All rights reserved.
# Copyright (c) 2009-2016 Cisco Systems, Inc.  All rights reserved.
# Copyright (c) 2016      Los Alamos National Security, LLC. All rights
#                         reserved.
# Copyright (c) 2017      Intel, Inc. All rights reserved.
# $COPYRIGHT$
#
# Additional copyrights may follow
#
# $HEADER$
#

# ORTE_CHECK_CRANE(prefix, [action-if-found], [action-if-not-found])
# --------------------------------------------------------
AC_DEFUN([ORTE_CHECK_CRANE],[
    if test -z "$orte_check_crane_happy" ; then
	AC_ARG_WITH([crane],
           [AC_HELP_STRING([--with-crane],
                           [Build CRANE scheduler component (default: yes)])])

	if test "$with_crane" = "no" ; then
            orte_check_crane_happy="no"
	elif test "$with_crane" = "" ; then
            # unless user asked, only build crane component on linux, AIX,
            # and OS X systems (these are the platforms that CRANE
            # supports)
            case $host in
		*-linux*|*-aix*|*-apple-darwin*)
                    orte_check_crane_happy="yes"
                    ;;
		*)
                    AC_MSG_CHECKING([for CRANE srun in PATH])
		    OPAL_WHICH([srun], [ORTE_CHECK_CRANE_SRUN])
                    if test "$ORTE_CHECK_CRANE_SRUN" = ""; then
			orte_check_crane_happy="no"
                    else
			orte_check_crane_happy="yes"
                    fi
                    AC_MSG_RESULT([$orte_check_crane_happy])
                    ;;
            esac
        else
            orte_check_crane_happy="yes"
        fi

        AS_IF([test "$orte_check_crane_happy" = "yes"],
              [AC_CHECK_FUNC([fork],
                             [orte_check_crane_happy="yes"],
                             [orte_check_crane_happy="no"])])

        AS_IF([test "$orte_check_crane_happy" = "yes"],
              [AC_CHECK_FUNC([execve],
                             [orte_check_crane_happy="yes"],
                             [orte_check_crane_happy="no"])])

        AS_IF([test "$orte_check_crane_happy" = "yes"],
              [AC_CHECK_FUNC([setpgid],
                             [orte_check_crane_happy="yes"],
                             [orte_check_crane_happy="no"])])

        # check to see if this is a Cray nativized crane env.

        crane_cray_env=0
        OPAL_CHECK_ALPS([orte_crane_cray],
                        [crane_cray_env=1])

        AC_DEFINE_UNQUOTED([CRANE_CRAY_ENV],[$crane_cray_env],
                           [defined to 1 if crane cray env, 0 otherwise])

        OPAL_SUMMARY_ADD([[Resource Managers]],[[Crane]],[$1],[$orte_check_crane_happy])
    fi

    AS_IF([test "$orte_check_crane_happy" = "yes"],
          [$2],
          [$3])
])
