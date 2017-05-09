// This is P4 sample source for ofdpa
// Fill in these files with your P4 code

#include "includes/constants.h"
#include "includes/p4_table_size.h"

#include "includes/headers.p4"
#include "includes/parser.p4"


/* Define metadata variables */
#include "includes/metadata.p4"
metadata my_ingress_metadata_t ingress_metadata;
metadata my_egress_metadata_t egress_metadata;


/* Ingress tables */
#include "tables_definitions/ingress_tables.p4"

/* Group tables */
#include "tables_definitions/group_tables.p4"

/* Egress tables */
#include "tables_definitions/egress_tables.p4"


/* Null actions, nop() and on_miss() */
#include "includes/null_actions.p4"

control ingress {
    apply(ingress_port) {
        hit {
            process_vlan();
        }
        miss {
            apply(policy_acl);
        }
    }

    // Policy ACL is a penultimate table;
    // L2 Interface is the last table. It is a 
    // group table.

}


control process_vlan() {
    apply(vlan) {
        hit {
            
        }
        miss {
            // clear actions. HOW???
            apply(policy_acl);
        }
    }
}





control egress {

}