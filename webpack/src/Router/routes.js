import React from 'react';
import WelcomePage from './WelcomePage';

const routes = [
  {
    path: '/agent_monitoring/welcome',
    exact: true,
    render: (props) => <WelcomePage {...props} />,
  },
];

export default routes;
