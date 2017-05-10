/*****************************************************************************/
/*                           OF-DPA pipeline of P4                           */
/* This program implements only part of OF-DPA. OF-DPA pipeline is vey       */ 
/* branchy and therefore all program execution was done using construction   */
/* with keyword 'control'(it is a like function in programming language).    */
/* Some tables were changed, because P4 does not allow flexibility in tables */
/* mathing definition. Construction 'reads' strictly fix the presence of     */
/* packet or metadata fields. All checkhing you need do in control function  */
/* using if-else construction or construction like case:                     */
/*                                                                           */
/*    apply(table1) {                                                        */
/*        table1_action1 {                                                   */
/*            some apply-constructions                                       */
/*        }                                                                  */
/*        table1_action2 {                                                   */
/*            some apply-constructions                                       */
/*        }                                                                  */
/*    }                                                                      */
/*                                                                           */
/*    or                                                                     */
/*                                                                           */
/*    apply(table1) {                                                        */
/*        hit {                                                              */
/*            some apply-constructions                                       */
/*        }                                                                  */
/*        miss {                                                             */
/*            some apply-constructions                                       */
/*        }                                                                  */
/*    }                                                                      */
/*****************************************************************************/


#include "includes/constants.h"
#include "includes/p4_table_size.h"

#include "includes/headers.p4"
#include "includes/parser.p4"


/* Define metadata variables */
#include "includes/metadata.p4"
metadata my_ingress_metadata_t ingress_metadata;
metadata my_egress_metadata_t egress_metadata;
metadata intrinsic_metadata_t intrinsic_metadata;


/* Ingress tables */
#include "tables_definitions/ingress_tables.p4"

/* Group tables */
#include "tables_definitions/group_tables.p4"

/* Egress tables */
#include "tables_definitions/egress_tables.p4"


/* Null actions, nop() and on_miss() */
#include "includes/null_actions.p4"

#include "includes/p4features.h"

control ingress {
    // process_ingress_port();

    if (2 > 1) {
        apply(ingress_port);
    } else if (3 > 4) {
        apply(ingress_port);
    }
}


control egress {

}