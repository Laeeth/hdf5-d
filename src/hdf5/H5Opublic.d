/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Copyright by The HDF Group.                                               *
 * Copyright by the Board of Trustees of the University of Illinois.         *
 * All rights reserved.                                                      *
 *                                                                           *
 * This file is part of HDF5.  The full HDF5 copyright notice, including     *
 * terms governing use, modification, and redistribution, is contained in    *
 * the files COPYING and Copyright.html.  COPYING can be found at the root   *
 * of the source code distribution tree; Copyright.html can be found at the  *
 * root level of an installed copy of the electronic HDF5 document set and   *
 * is linked from the top-level documents page.  It can also be found at     *
 * http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          *
 * access to either file, you may request a copy from help@hdfgroup.org.     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

module hdf5.H5Opublic;

/*-------------------------------------------------------------------------
 *
 * Created:             H5Opublic.h
 *                      Aug  5 1997
 *                      Robb Matzke <matzke@llnl.gov>
 *
 * Purpose:             Public declarations for the H5O (object header)
 *                      package.
 *
 *-------------------------------------------------------------------------
 */

/* Public headers needed by this file */
public import core.stdc.stdint;

import hdf5.H5public;
import hdf5.H5Ipublic;
import hdf5.H5Lpublic;

extern(C):

/*****************/
/* Public Macros */
/*****************/

/* Flags for object copy (H5Ocopy) */
enum H5O_COPY_SHALLOW_HIERARCHY_FLAG = (0x0001u);   /* Copy only immediate members */
enum H5O_COPY_EXPAND_SOFT_LINK_FLAG  = (0x0002u);   /* Expand soft links into new objects */
enum H5O_COPY_EXPAND_EXT_LINK_FLAG   = (0x0004u);   /* Expand external links into new objects */
enum H5O_COPY_EXPAND_REFERENCE_FLAG  = (0x0008u);   /* Copy objects that are pointed by references */
enum H5O_COPY_WITHOUT_ATTR_FLAG      = (0x0010u);   /* Copy object without copying attributes */
enum H5O_COPY_PRESERVE_NULL_FLAG     = (0x0020u);   /* Copy NULL messages (empty space) */
enum H5O_COPY_MERGE_COMMITTED_DTYPE_FLAG = (0x0040u);   /* Merge committed datatypes in dest file */
enum H5O_COPY_ALL                    =(0x007Fu);   /* All object copying flags (for internal checking) */

/* Flags for shared message indexes.
 * Pass these flags in using the mesg_type_flags parameter in
 * H5P_set_shared_mesg_index.
 * (Developers: These flags correspond to object header message type IDs,
 * but we need to assign each kind of message to a different bit so that
 * one index can hold multiple types.)
 */
enum H5O_SHMESG_NONE_FLAG    = 0x0000;          /* No shared messages */
enum H5O_SHMESG_SDSPACE_FLAG = (cast(uint)1 << 0x0001); /* Simple Dataspace Message.  */
enum H5O_SHMESG_DTYPE_FLAG   = (cast(uint)1 << 0x0003); /* Datatype Message.  */
enum H5O_SHMESG_FILL_FLAG    = (cast(uint)1 << 0x0005); /* Fill Value Message. */
enum H5O_SHMESG_PLINE_FLAG   = (cast(uint)1 << 0x000b); /* Filter pipeline message.  */
enum H5O_SHMESG_ATTR_FLAG    = (cast(uint)1 << 0x000c); /* Attribute Message.  */
enum H5O_SHMESG_ALL_FLAG     = (H5O_SHMESG_SDSPACE_FLAG | H5O_SHMESG_DTYPE_FLAG | H5O_SHMESG_FILL_FLAG | H5O_SHMESG_PLINE_FLAG | H5O_SHMESG_ATTR_FLAG);

/* Object header status flag definitions */
enum H5O_HDR_CHUNK0_SIZE             = 0x03;    /* 2-bit field indicating # of bytes to store the size of chunk 0's data */
enum H5O_HDR_ATTR_CRT_ORDER_TRACKED  = 0x04;    /* Attribute creation order is tracked */
enum H5O_HDR_ATTR_CRT_ORDER_INDEXED  = 0x08;    /* Attribute creation order has index */
enum H5O_HDR_ATTR_STORE_PHASE_CHANGE = 0x10;    /* Non-default attribute storage phase change values stored */
enum H5O_HDR_STORE_TIMES             = 0x20;    /* Store access, modification, change & birth times for object */
enum H5O_HDR_ALL_FLAGS = (H5O_HDR_CHUNK0_SIZE | H5O_HDR_ATTR_CRT_ORDER_TRACKED | H5O_HDR_ATTR_CRT_ORDER_INDEXED | H5O_HDR_ATTR_STORE_PHASE_CHANGE | H5O_HDR_STORE_TIMES);

/* Maximum shared message values.  Number of indexes is 8 to allow room to add
 * new types of messages.
 */
enum H5O_SHMESG_MAX_NINDEXES = 8;
enum H5O_SHMESG_MAX_LIST_SIZE = 5000;

/*******************/
/* Public Typedefs */
/*******************/

/* Types of objects in file */
enum H5O_type_t {
    H5O_TYPE_UNKNOWN = -1,	/* Unknown object type		*/
    H5O_TYPE_GROUP,	        /* Object is a group		*/
    H5O_TYPE_DATASET,		/* Object is a dataset		*/
    H5O_TYPE_NAMED_DATATYPE, 	/* Object is a named data type	*/
    H5O_TYPE_NTYPES             /* Number of different object types (must be last!) */
}

/* Information struct for object header metadata (for H5Oget_info/H5Oget_info_by_name/H5Oget_info_by_idx) */
struct H5O_hdr_info_t {
    uint _version;		/* Version number of header format in file */
    uint nmesgs;		/* Number of object header messages */
    uint nchunks;		/* Number of object header chunks */
    uint flags;             /* Object header status flags */
    struct space {
        hsize_t total;		/* Total space for storing object header in file */
        hsize_t meta;		/* Space within header for object header metadata information */
        hsize_t mesg;		/* Space within header for actual message information */
        hsize_t free;		/* Free space within object header */
    }
    struct mesg {
        uint64_t present;	/* Flags to indicate presence of message type in header */
        uint64_t _shared;	/* Flags to indicate message type is shared in header */
    }
}

/* Information struct for object (for H5Oget_info/H5Oget_info_by_name/H5Oget_info_by_idx) */
struct H5O_info_t {
    uint 	fileno;		/* File number that object is located in */
    haddr_t 		addr;		/* Object address in file	*/
    H5O_type_t 		type;		/* Basic object type (group, dataset, etc.) */
    uint 		rc;		/* Reference count of object    */
    time_t		atime;		/* Access time			*/
    time_t		mtime;		/* Modification time		*/
    time_t		ctime;		/* Change time			*/
    time_t		btime;		/* Birth time			*/
    hsize_t 		num_attrs;	/* # of attributes attached to object */
    H5O_hdr_info_t      hdr;            /* Object header information */
    /* Extra metadata storage for obj & attributes */
    struct meta_size {
        H5_ih_info_t   obj;             /* v1/v2 B-tree & local/fractal heap for groups, B-tree for chunked datasets */
        H5_ih_info_t   attr;            /* v2 B-tree & heap for attributes */
    }
}

/* Typedef for message creation indexes */
alias H5O_msg_crt_idx_t = uint32_t;

/* Prototype for H5Ovisit/H5Ovisit_by_name() operator */
alias H5O_iterate_t = herr_t function(hid_t obj, const char *name, const H5O_info_t *info,
    void *op_data);

enum H5O_mcdt_search_ret_t {
    H5O_MCDT_SEARCH_ERROR = -1,	/* Abort H5Ocopy */
    H5O_MCDT_SEARCH_CONT,	/* Continue the global search of all committed datatypes in the destination file */
    H5O_MCDT_SEARCH_STOP	/* Stop the search, but continue copying.  The committed datatype will be copied but not merged. */
};

/* Callback to invoke when completing the search for a matching committed datatype from the committed dtype list */
alias H5O_mcdt_search_cb_t = H5O_mcdt_search_ret_t function(void *op_data);

/********************/
/* Public Variables */
/********************/

version(Posix) {
/*********************/
/* Public Prototypes */
/*********************/
hid_t H5Oopen(hid_t loc_id, const char *name, hid_t lapl_id);
hid_t H5Oopen_by_addr(hid_t loc_id, haddr_t addr);
hid_t H5Oopen_by_idx(hid_t loc_id, const char *group_name,
    H5_index_t idx_type, H5_iter_order_t order, hsize_t n, hid_t lapl_id);
htri_t H5Oexists_by_name(hid_t loc_id, const char *name, hid_t lapl_id);
herr_t H5Oget_info(hid_t loc_id, H5O_info_t *oinfo);
herr_t H5Oget_info_by_name(hid_t loc_id, const char *name, H5O_info_t *oinfo,
    hid_t lapl_id);
herr_t H5Oget_info_by_idx(hid_t loc_id, const char *group_name,
    H5_index_t idx_type, H5_iter_order_t order, hsize_t n, H5O_info_t *oinfo,
    hid_t lapl_id);
herr_t H5Olink(hid_t obj_id, hid_t new_loc_id, const char *new_name,
    hid_t lcpl_id, hid_t lapl_id);
herr_t H5Oincr_refcount(hid_t object_id);
herr_t H5Odecr_refcount(hid_t object_id);
herr_t H5Ocopy(hid_t src_loc_id, const char *src_name, hid_t dst_loc_id,
    const char *dst_name, hid_t ocpypl_id, hid_t lcpl_id);
herr_t H5Oset_comment(hid_t obj_id, const char *comment);
herr_t H5Oset_comment_by_name(hid_t loc_id, const char *name,
    const char *comment, hid_t lapl_id);
ssize_t H5Oget_comment(hid_t obj_id, char *comment, size_t bufsize);
ssize_t H5Oget_comment_by_name(hid_t loc_id, const char *name,
    char *comment, size_t bufsize, hid_t lapl_id);
herr_t H5Ovisit(hid_t obj_id, H5_index_t idx_type, H5_iter_order_t order,
    H5O_iterate_t op, void *op_data);
herr_t H5Ovisit_by_name(hid_t loc_id, const char *obj_name,
    H5_index_t idx_type, H5_iter_order_t order, H5O_iterate_t op,
    void *op_data, hid_t lapl_id);
herr_t H5Oclose(hid_t object_id);
}

/++ DEPRECATED
/* Symbols defined for compatibility with previous versions of the HDF5 API.
 *
 * Use of these symbols is deprecated.
 */
#ifndef H5_NO_DEPRECATED_SYMBOLS

/* Macros */

/* Typedefs */

/* A struct that's part of the H5G_stat_t routine (deprecated) */
typedef struct H5O_stat_t {
    hsize_t size;               /* Total size of object header in file */
    hsize_t free;               /* Free space within object header */
    unsigned nmesgs;            /* Number of object header messages */
    unsigned nchunks;           /* Number of object header chunks */
} H5O_stat_t;

/* Function prototypes */

#endif /* H5_NO_DEPRECATED_SYMBOLS */
+/

