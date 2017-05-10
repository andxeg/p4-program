/*****************************************************************************/
/*                              Packet Parser                                */
/* See only Ethernet, VLAN, QinQ, IPv4, IPv6, TCP, UDP                       */
/*****************************************************************************/

parser start {
    #ifdef INGRESS_PORT_MAPPING_DISABLE 
        set_metadata(ingress_metadata.tunnel_id, 0);
        set_metadata(ingress_metadata.lmep_id, 0);
    #endif


    /* Set intrinsic metadata*/
    set_metadata(intrinsic_metadata.ingress_port_hit, 0);
    set_metadata(intrinsic_metadata.ingress_port_set_vrf, 0);
    set_metadata(intrinsic_metadata.ingress_port_not_set_vrf, 0);

    set_metadata(intrinsic_metadata.vlan_modify_vlan_tag, 0);
    set_metadata(intrinsic_metadata.vlan_pop_vlan_tag, 0);
    set_metadata(intrinsic_metadata.vlan_pass, 0);

    set_metadata(intrinsic_metadata.vlan_1_hit, 0);
    set_metadata(intrinsic_metadata.vlan_1_modify_vlan_1_tag, 0);
    set_metadata(intrinsic_metadata.vlan_1_pop_vlan_1_tag, 0);
    
    set_metadata(intrinsic_metadata.vlan_2_hit, 0);

    set_metadata(intrinsic_metadata.termination_mac_hit, 0);

    set_metadata(intrinsic_metadata.l3_type_v4_hit, 0);
    set_metadata(intrinsic_metadata.l3_type_v6_hit, 0);

    set_metadata(intrinsic_metadata.unicast_routing_ipv4_hit, 0);
    set_metadata(intrinsic_metadata.unicast_routing_ipv6_hit, 0);
    
    set_metadata(intrinsic_metadata.multicast_routing_ipv4_hit, 0);        
    set_metadata(intrinsic_metadata.multicast_routing_ipv6_hit, 0);


    set_metadata(intrinsic_metadata.bridging_hit, 0);
    set_metadata(intrinsic_metadata.unicast_overlay_hit, 0);
    set_metadata(intrinsic_metadata.dlf_vlan_hit, 0);

    /* Set ingress metadata*/
    set_metadata(ingress_metadata.mask_l2_multicast_IPv4, 0);
    set_metadata(ingress_metadata.mask_l2_multicast_IPv6, 0);

    set_metadata(ingress_metadata.mask_l3_multicast_IPv4, 0);
    set_metadata(ingress_metadata.mask_l3_multicast_IPv6, 0);

    set_metadata(ingress_metadata.mask_l2_for_vlan_cast, 0)
    
    return parse_ethernet;
}


#define ETHERTYPE_VLAN         0x8100, 0x9100, 0x9200, 0x9300
#define ETHERTYPE_ONE_VLAN     0x8100
#define ETHERTYPE_QINQ         0x9100
#define ETHERTYPE_IPV4         0x0800
#define ETHERTYPE_IPV6         0x86dd


/* Tunnel types */
#define INGRESS_TUNNEL_TYPE_NONE               0

#define PARSE_ETHERTYPE                                    \
        ETHERTYPE_VLAN : parse_vlan;                       \
        ETHERTYPE_IPV4 : parse_ipv4;                       \
        ETHERTYPE_IPV6 : parse_ipv6;                       \
        default: ingress

#define PARSE_ETHERTYPE_MINUS_VLAN                         \
        ETHERTYPE_IPV4 : parse_ipv4;                       \
        ETHERTYPE_IPV6 : parse_ipv6;                       \
        default: ingress


header ethernet_t ethernet;
parser parse_ethernet {
    extract(ethernet);
    return select(latest.etherType) {
        PARSE_ETHERTYPE;
    }
}



#define VLAN_DEPTH 2
header vlan_tag_t vlan_tag_[VLAN_DEPTH];
parser parse_vlan {
    extract(vlan_tag_[next]);
    return select(latest.etherType) {
        PARSE_ETHERTYPE;
    }
}

// header vlan_tag_t vlan_inner;
// header vlan_tag_t vlan_outer;

// parser parse_vlan {
//     extract(vlan_outer);
//     return select(latest.etherType) {
//         PARSE_ETHERTYPE_MINUS_VLAN;
//     }
// }

// parser parse_qinq {
//     extract(vlan_outer);
//     return select(latest.etherType) {
//         ETHERTYPE_VLAN : parse_qinq_vlan;
//         default : ingress;
//     }
// }

// parser parse_qinq_vlan {
//     extract(vlan_inner);
//     return select(latest.etherType) {
//         PARSE_ETHERTYPE_MINUS_VLAN;
//     }
// }


#define IP_PROTOCOLS_IPV4              4
#define IP_PROTOCOLS_TCP               6
#define IP_PROTOCOLS_UDP               17
#define IP_PROTOCOLS_IPV6              41


#define IP_PROTOCOLS_IPHL_TCP          0x506
#define IP_PROTOCOLS_IPHL_UDP          0x511

header ipv4_t ipv4;

field_list ipv4_checksum_list {
        ipv4.version;
        ipv4.ihl;
        ipv4.diffserv;
        ipv4.totalLen;
        ipv4.identification;
        ipv4.flags;
        ipv4.fragOffset;
        ipv4.ttl;
        ipv4.protocol;
        ipv4.srcAddr;
        ipv4.dstAddr;
}

field_list_calculation ipv4_checksum {
    input {
        ipv4_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field ipv4.hdrChecksum  {
    verify ipv4_checksum;
    update ipv4_checksum;
}


parser parse_ipv4 {
    extract(ipv4);
    return select(latest.fragOffset, latest.ihl, latest.protocol) {
        IP_PROTOCOLS_IPHL_TCP : parse_tcp;
        IP_PROTOCOLS_IPHL_UDP : parse_udp;
        default: ingress;
    }
}


header ipv6_t ipv6; 
parser parse_ipv6 {
    extract(ipv6);
    return select(latest.nextHdr) {
        IP_PROTOCOLS_TCP : parse_tcp;
        IP_PROTOCOLS_UDP : parse_udp;
        default: ingress;
    }
}


header tcp_t tcp;
parser parse_tcp {
    extract(tcp);
    set_metadata(ingress_metadata.lkp_l4_sport, latest.srcPort);
    set_metadata(ingress_metadata.lkp_l4_dport, latest.dstPort);
    return ingress;
}


header udp_t udp;
parser parse_udp {
    extract(udp);
    set_metadata(ingress_metadata.lkp_l4_sport, latest.srcPort);
    set_metadata(ingress_metadata.lkp_l4_dport, latest.dstPort);
    return ingress;
}
