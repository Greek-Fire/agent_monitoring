import { combineReducers } from 'redux';
import EmptyStateReducer from './Components/EmptyState/EmptyStateReducer';

const reducers = {
  agentMonitoring: combineReducers({
    emptyState: EmptyStateReducer,
  }),
};

export default reducers;
