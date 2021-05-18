import rospy
from gazebo_msgs.msg import ModelState
from gazebo_msgs.srv import SetModelState
# OJ 18.5.21 - EMR--SS21
# Versuch, die Odometrie des youBots auf Null zu setzen
# get existing model_states
# $ rostopic echo -n 1 /gazebo/model_states
"""
$ rosservice call /gazebo/set_model_state '{model_state: { model_name: youbot, pose: { position: { x: 0.0, y: 0.0 ,z: 0.1 }, orientation: {x: 0.0, y: 0.0, z: 0.0, w: 0.0 } }, twist: { linear: {x: 0.0 , y: 0 ,z: 0 } , angular: { x: 0.0 , y: 0 , z: 0.0 } } , reference_frame: world } }'
success: True
status_message: "SetModelState: set model state done"
"""


def main():
    rospy.init_node('reset_odom_pose')

    state_msg = ModelState()
    state_msg.model_name = 'youbot'
    state_msg.reference_frame = 'world'
    state_msg.pose.position.x = 0.0
    state_msg.pose.position.y = 0.0
    state_msg.pose.position.z = 0.0
    state_msg.pose.orientation.x = 0.0
    state_msg.pose.orientation.y = 0.0
    state_msg.pose.orientation.z = 0.0
    state_msg.pose.orientation.w = 0.0

    rospy.wait_for_service('/gazebo/set_model_state')
    try:
        set_state = rospy.ServiceProxy('/gazebo/set_model_state',
                                       SetModelState)
        set_state(state_msg)

    except rospy.ServiceException:
        print("Service call failed")


if __name__ == '__main__':
    try:
        main()
    except rospy.ROSInterruptException:
        pass
