export const mockResults = {
  searchInformation: {
    totalCount: 100,
  },
  items: [
    {
      title: 'Lorem ipsum dolor sit amet',
      link: 'https://example.com/1',
    },
    {
      title: 'Consectetur adipiscing elit',
      link: 'https://example.com/2',
    },
    {
      title: 'Sed do eiusmod tempor incididunt',
      link: 'https://example.com/3',
    },
    {
      title: 'Ut labore et dolore magna aliqua',
      link: 'https://example.com/4',
    },
    {
      title: 'Mauris blandit aliquet elit',
      link: 'https://example.com/5',
    },
    {
      title: 'Pellentesque euismod magna',
      link: 'https://example.com/6',
    },
    {
      title: 'Vestibulum ac diam sit amet quam',
      link: 'https://example.com/7',
    },
    {
      title: 'Cras ultricies ligula sed magna',
      link: 'https://example.com/8',
    },
    {
      title: 'Vivamus magna justo',
      link: 'https://example.com/9',
    },
    {
      title: 'Curabitur blandit tempus porttitor',
      link: 'https://example.com/10',
    },
  ],
};

export const mockNoResults = {
  searchInformation: {
    totalCount: 0,
  },
  items: [],
};

export const mockErrorResults = {
  error: {
    code: 403,
    message: 'The request is missing a valid API key.',
    errors: [
      {
        message: 'The request is missing a valid API key.',
        domain: 'global',
        reason: 'forbidden',
      },
    ],
    status: 'PERMISSION_DENIED',
  },
};
