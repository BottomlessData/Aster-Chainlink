import { Icon } from '@iconify/react';
import plusFill from '@iconify/icons-eva/plus-fill';
import { Link as RouterLink } from 'react-router-dom';
// material
import { Grid, Button, Container, Stack, Typography } from '@mui/material';

import TaskPostCard from 'src/components/MicroTask/TaskPostCard';
import React, { useState, useEffect } from 'react';
import axios from 'axios';

import Web3 from 'web3'
import { InjectedConnector } from '@web3-react/injected-connector'
import { useWeb3React } from "@web3-react/core"

import { task_contract } from '../DataLabel/abi';
import { Box } from '@mui/system';


const injected = new InjectedConnector({
  supportedChainIds: [80001],
})

const web3 = new Web3(Web3.givenProvider);

// ----------------------------------------------------------------------

export default function MaticPrice() {
    const [TASKLIST, setTASKLIST] = useState([]);
    const { active, account, library, connector, activate, deactivate } = useWeb3React();
    const [maticPrice, setMaticPrice] = useState(0);

  const getMaticToUSDPrice = async () => {
    if(!active){
      try {
        await activate(injected);
      } catch (ex) {
        console.log(ex)
      }
    }
    const TaskContract = new web3.eth.Contract(task_contract.abi, TASKLIST[0].contract_address);
    const tx = await TaskContract.methods.getLatestPrice().call();
    console.log(tx);
    setMaticPrice(tx/(10**8));
  } 

    const loadTaskList = async () => {
        const response = await axios('https://us-central1-aster-chainlink.cloudfunctions.net/api/tasks');
        const task_list = response.data.map((task) => {
          return {
            id: task.id,
            name: task.name,
            task:'image classification',
            dataType: 'image',
            offer: task.total_price + " MATIC",
            status: 'in progress',
            contract_address: task.contract_id,
            number_of_labelers: task.number_of_labelers,
            number_of_submission: task.number_of_submission,
            description: task.description,
            total_price: task.total_price
          }
        });
    
        setTASKLIST(task_list);
    };
    
  useEffect(()=>{
    loadTaskList();
  },[]);


  return (
        <Container>
          {
              maticPrice == 0 ? 
              <Button onClick={getMaticToUSDPrice}>MATIC to USD</Button>
              :
              <div>
              <Typography variant="h6">{"1 MATIC = " + maticPrice + " USD"}</Typography>
              <Button onClick={getMaticToUSDPrice}>refresh</Button>
              </div>
          }
          
          <Box sx={{height: 10}}/>
          <Grid container spacing={3}>
            {TASKLIST.map((post, index) => (
              <TaskPostCard key={post.id} post={post} index={index} maticPrice={maticPrice}/>
            ))}
          </Grid>

        </Container>
  );
}
