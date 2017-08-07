#!/bin/bash
#--------------------------------------------------------------------------------#
#                 LUW-FLAVOR - GERENCIAMENTO DE RECURSOS                         #
#                  CREATED BY: maik.alberto@hotmail.com                          #
#                              Em construcao                                     #
#--------------------------------------------------------------------------------#

echo "<pre>"
echo "<input type='checkbox' name='FLAVORHAB' value='enable'>Habilitar Flavor"
echo "<br>"
echo "<textarea name='contable' rows='10' cols='50'>"
        tail -n +2 /opt/luw/config/flavor
echo "</textarea>"
echo "<br>"
echo "<input type='submit' name='save' value='save'>"
exit 0
