import { Icon } from '@iconify/react';
import plusFill from '@iconify/icons-eva/plus-fill';
import { Link as RouterLink } from 'react-router-dom';
// material
import { Grid, Button, Container, Stack, Typography } from '@mui/material';
// components
import Page from '../components/Page';
import { BlogPostsSort, BlogPostsSearch } from '../components/_dashboard/blog';
//
import POSTS from '../_mocks_/blog';
import TaskPostCard from 'src/components/MicroTask/TaskPostCard';
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import MaticPrice from 'src/components/MicroTask/MaticPrice';


import Web3 from 'web3'
import { Web3ReactProvider } from '@web3-react/core'


function getLibrary(provider) {
  return new Web3(provider)
}



// ----------------------------------------------------------------------

const SORT_OPTIONS = [
  { value: 'latest', label: 'Latest' },
  { value: 'popular', label: 'Popular' },
  { value: 'oldest', label: 'Oldest' }
];

// ----------------------------------------------------------------------

export default function MicroTask() {

  return (
    <Page title="Classify Task">
        <Container>
          <Stack direction="row" alignItems="center" justifyContent="space-between" mb={5}>
            <Typography variant="h4" gutterBottom>
              Classify Task
            </Typography>
          </Stack>

          <Stack mb={5} direction="row" alignItems="center" justifyContent="space-between">
            <BlogPostsSearch posts={POSTS} />
            <BlogPostsSort options={SORT_OPTIONS} />
          </Stack>

          <Web3ReactProvider getLibrary={getLibrary} >
            <MaticPrice />
          </Web3ReactProvider>

        </Container>
    </Page>
  );
}
