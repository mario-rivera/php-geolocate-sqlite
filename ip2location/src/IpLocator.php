<?php 
namespace mrivera\ip2location;

use SQLite3;
use Exception;

class IpLocator{
    
    public function __construct(SQLite3 $sqlite){
        
        $this->sqlite = $sqlite;
    }
    
    public function locate( $ip ){
        
        $this->validateIp($ip);
        
        $iplong = $this->getIpLong( $ip );
        $result = $this->queryIpLocation($iplong);
        
        return ( $result === false ) ? [] : $result;
    }
    
    private function validateIp($ip){
        
        if( !filter_var($ip, FILTER_VALIDATE_IP) ){
            
            throw new Exception('Invalid ip');
        }
        
        return true;
    }
    
    private function getIpLong($ip){
        
        return ip2long($ip);
    }
    
    private function queryIpLocation($iplong){
        
        $query = "SELECT * FROM ip2location_db3" . PHP_EOL;
        $query .= "WHERE ip_from <= ${iplong} AND ip_to >= ${iplong}";
        
        return $this->sqlite->querySingle($query, true);
    }
}