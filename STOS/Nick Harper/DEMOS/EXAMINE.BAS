Lionpoulos  	�  	�                                                             * � - Object examiner by Darren Ithell    d��� ��    n���   �    x�ͦ:��:���:��       D ����:� �
��F$�(�    *.3DO,�    Please select an object):���    ����Nj�    �   " ����:��� �
��F$:� Nv�    �    ���   �   , �� - Position object within the 3D world   ��  : ����   ,��
��F$,�    ,�    ,�    ,�    ,�    ,�       H ܊ - Position the view point (object 0) so that it looks towards the   � - physical objects   2 ���    ,�    ,�    ,��   �:���     ,�      � - Set the palette  >�palette 0,$777,0,0,0,0,0,0,0,$777,$127,$666,$555,0,$444   ��:���  L"� - OX, OY, XD and YD are used to work out how far the mouse has moved   *,� - and in which direction every loop  6� -  @� - Main redraw loop   J� -  T�  W   ^� -  Dh� - Set OX and OY to the same as the current mouse X,Y position  Lr� - Also set the mouse into the centre of the screen so that a relative  $|� - movement can be monitored.   �� -  6�� 
��OX��   �:���
��OX:�
��OY��   d:���
��OY   �� -  L�� - Movement of the viewpoint. Depends on user's input via the mouse     �� -  &�� - Turn Viewpoint left and right   -  "̨��    ,�    ,�
��LR,�       ֊ -   �� - Move Viewpoint forward   � -  ����    ,�
��FB   �� -  B� - Move Viewpoint up and down (if left mouse button pressed)  � -  "���    ,�    ,�
��UD,�       &� -  .0� - Spin the disc in front of the monitor  :� -  l� -  .v� - Clear the screen and draw all objects  �� -  
����   
����   ڊ -  F� - Get coordinates and angles of the viewpoint and display them   N� - onto the screen. (This helps you set start points in games and demos)  �� -  R� -  <\� - Sync the screen redraw with the next vertical blank  f� -  p�  z��   �� -  J�� - Check to see if the user has moved the mouse for the next update   �� 
��XD����
��OX   �� 
��YD����
��OY   0�� 
��LR��    :�
��FB��    :�
��UD��       �� �
��I$�(�)   *����
��I$��    �   ��:�     �    x   :����
��I$��   s�   �t:����   F$��   .3DO��   .neo   �� -  8�� - If mouse has been moved left and right, set LR   �� 
��LR��
��XD��   
   Ԋ -  *ފ - If mouse moved up or down, set FB  �� 
��FB��
��YD���       � -  &�� - If left mouse pressed, set UD  8����   �    � 
��UD��
��YD��   :�
��FB��       � -  B� - If right button pressed, view point to face spinning disc  "$����   �    ���    ,�      .���   