// This file contains sizes of pipeline tables

#define MIN_SIZE                             512

/* Ingress tables */
#define INGRESS_PORT_MAPPING_FLOW_TABLE_SIZE MIN_SIZE
#define INGRESS_PORT_FLOW_TABLE_SIZE         MIN_SIZE
#define VLAN_FLOW_TABLE_SIZE                 MIN_SIZE
#define VLAN_1_FLOW_TABLE_SIZE               MIN_SIZE
#define TERMINATION_MAC_FLOW_TABLE_SIZE      MIN_SIZE
#define L3_TYPE_FLOW_TABLE_SIZE              MIN_SIZE
#define UNICAST_ROUTING_FLOW_TABLE_SIZE      MIN_SIZE
#define MULTICAST_ROUTING_FLOW_TABLE_SIZE    MIN_SIZE
#define BRIDGING_FLOW_TABLE_SIZE             MIN_SIZE
#define POLICY_ACL_TABLE_SIZE                MIN_SIZE



/* Egress tables */
#define EGRESS_TABLE_SIZE                    MIN_SIZE