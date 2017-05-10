
header_type my_ingress_metadata_t {
    fields {
        tunnel_id           : 17;            /* SEE includes/readme.json */
        lmep_id             : 32;            /* SEE includes/readme.json */
        vrf                 : VRF_BIT_WIDTH; /* VRF */
        lkp_l4_sport        : 16;
        lkp_l4_dport        : 16;
        mask_l2_multicast_IPv4 : 48;            /* mask eth_dst with ff-ff-ff-80-00-00 for IPv4 multicast */
        mask_l2_multicast_IPv6 : 48;            /* mask eth_dst with ff-ff-00-00-00-00 for IPv6 multicast */

        mask_l3_multicast_IPv4 : 32;            /* mask ip_dst with 224.0.0.0 for IPv4 multicast */
        mask_l3_multicast_IPv6 : 32;            /* mask ip_dst ff00:0:0:0:0:0:0:0 for IPv6 multicast */

        mask_l2_for_vlan_cast   : 48;            /* unicast or multicast*/

    }
}

