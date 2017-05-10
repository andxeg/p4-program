/*****************************************************************************/
/*                              VLAN flow table                              */
/*                Implement only with outer VLAN label                       */
/*                     Outer lable is vlan_tag_[0]                           */
/*****************************************************************************/



action modify_vlan_tag() {

}

action pop_vlan_tag() {

}


table vlan {
    reads {
        standard_metadata.ingress_port : exact;
        vlan_tag_[0].vid               : exact;
    }
    actions {
        modify_vlan_tag;
        pop_vlan_tag;
    }
    size : VLAN_FLOW_TABLE_SIZE;
}



control process_vlan {
    // Check vlan labels.
    // You must check existence of VLAN labels.
    // If vlan_tag_[1] is existed then vlan_tag_[0] is also existed.

    if (valid(vlan_tag_[0]) and valid(vlan_tag_[1])) {
        // process outer vlan label in double tagged packet
        apply(vlan) {
            hit {
                if (not valid(vlan_tag_[0])) {
                    // If label was popped.
                    process_vlan_1();
                } else {
                    // If label was modified
                    process_termination_mac();
                }
            }
            miss {
                process_policy_acl();
            }
        }
    } else if (valid(vlan_tag_[0]) and not valid(vlan_tag_[1])) {
        // process outer vlan label in single tagged packet
        apply(vlan) {
            hit {
                if (not valid(vlan_tag_[0])) {
                    // If label was popped.
                    process_termination_mac();
                } else {
                    // If label was modified
                    // process_vlan_1();
                }
            }
            miss {
                process_policy_acl(); // Delete
            }
        }
    }
}



//=============================================================================

// action set_valid_outer_unicast_packet_untagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_UNICAST);
//     modify_field(l2_metadata.lkp_mac_type, ethernet.etherType);
// }

// action set_valid_outer_unicast_packet_single_tagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_UNICAST);
//     modify_field(l2_metadata.lkp_mac_type, vlan_tag_[0].etherType);
//     modify_field(l2_metadata.lkp_pcp, vlan_tag_[0].pcp);
// }

// action set_valid_outer_unicast_packet_double_tagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_UNICAST);
//     modify_field(l2_metadata.lkp_mac_type, vlan_tag_[1].etherType);
//     modify_field(l2_metadata.lkp_pcp, vlan_tag_[0].pcp);
// }

// action set_valid_outer_unicast_packet_qinq_tagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_UNICAST);
//     modify_field(l2_metadata.lkp_mac_type, ethernet.etherType);
//     modify_field(l2_metadata.lkp_pcp, vlan_tag_[0].pcp);
// }

// action set_valid_outer_multicast_packet_untagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_MULTICAST);
//     modify_field(l2_metadata.lkp_mac_type, ethernet.etherType);
// }

// action set_valid_outer_multicast_packet_single_tagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_MULTICAST);
//     modify_field(l2_metadata.lkp_mac_type, vlan_tag_[0].etherType);
//     modify_field(l2_metadata.lkp_pcp, vlan_tag_[0].pcp);
// }

// action set_valid_outer_multicast_packet_double_tagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_MULTICAST);
//     modify_field(l2_metadata.lkp_mac_type, vlan_tag_[1].etherType);
//     modify_field(l2_metadata.lkp_pcp, vlan_tag_[0].pcp);
// }

// action set_valid_outer_multicast_packet_qinq_tagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_MULTICAST);
//     modify_field(l2_metadata.lkp_mac_type, ethernet.etherType);
//     modify_field(l2_metadata.lkp_pcp, vlan_tag_[0].pcp);
// }

// action set_valid_outer_broadcast_packet_untagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_BROADCAST);
//     modify_field(l2_metadata.lkp_mac_type, ethernet.etherType);
// }

// action set_valid_outer_broadcast_packet_single_tagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_BROADCAST);
//     modify_field(l2_metadata.lkp_mac_type, vlan_tag_[0].etherType);
//     modify_field(l2_metadata.lkp_pcp, vlan_tag_[0].pcp);
// }

// action set_valid_outer_broadcast_packet_double_tagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_BROADCAST);
//     modify_field(l2_metadata.lkp_mac_type, vlan_tag_[1].etherType);
//     modify_field(l2_metadata.lkp_pcp, vlan_tag_[0].pcp);
// }

// action set_valid_outer_broadcast_packet_qinq_tagged() {
//     modify_field(l2_metadata.lkp_pkt_type, L2_BROADCAST);
//     modify_field(l2_metadata.lkp_mac_type, ethernet.etherType);
//     modify_field(l2_metadata.lkp_pcp, vlan_tag_[0].pcp);
// }

// action malformed_outer_ethernet_packet(drop_reason) {
//     modify_field(ingress_metadata.drop_flag, TRUE);
//     modify_field(ingress_metadata.drop_reason, drop_reason);
// }

// table validate_outer_ethernet {
//     reads {
//         ethernet.srcAddr : ternary;
//         ethernet.dstAddr : ternary;
//         vlan_tag_[0] : valid;
//         vlan_tag_[1] : valid;
//     }
//     actions {
//         malformed_outer_ethernet_packet;
//         set_valid_outer_unicast_packet_untagged;
//         set_valid_outer_unicast_packet_single_tagged;
//         set_valid_outer_unicast_packet_double_tagged;
//         set_valid_outer_unicast_packet_qinq_tagged;
//         set_valid_outer_multicast_packet_untagged;
//         set_valid_outer_multicast_packet_single_tagged;
//         set_valid_outer_multicast_packet_double_tagged;
//         set_valid_outer_multicast_packet_qinq_tagged;
//         set_valid_outer_broadcast_packet_untagged;
//         set_valid_outer_broadcast_packet_single_tagged;
//         set_valid_outer_broadcast_packet_double_tagged;
//         set_valid_outer_broadcast_packet_qinq_tagged;
//     }
//     size : VALIDATE_PACKET_TABLE_SIZE;
// }

// control process_validate_outer_header {
//     /* validate the ethernet header */
//     apply(validate_outer_ethernet) {
//         malformed_outer_ethernet_packet {
//         }
//         default {
//             if (valid(ipv4)) {
//                 validate_outer_ipv4_header();
//             } else {
//                 if (valid(ipv6)) {
//                     validate_outer_ipv6_header();
//                 } else {
// #ifndef MPLS_DISABLE
//                     if (valid(mpls[0])) {
//                         validate_mpls_header();
//                     }
// #endif
//                 }
//             }
//         }
//     }
// }
