/*****************************************************************************/
/*                           L2 Interface Group Table                        */
/*****************************************************************************/


action l2_interface_action(output_port) {
    modify_field(standard_metadata.egress_spec, output_port);
}


table l2_interface {
    actions {
        l2_interface_action;       
    }
    size : L2_INTERFACE_GROUP_TABLE_SIZE;
}


control process_l2_interface {
    apply(l2_interface);
}